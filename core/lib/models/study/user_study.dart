import 'dart:math';

import 'package:fhir/r4.dart' as fhir;
import 'package:postgrest/postgrest.dart';
import 'package:quiver/collection.dart';
import 'package:studyou_core/models/study/supabase_object.dart';

import '../../util/extensions.dart';
import '../models.dart';
import 'contact.dart';

class UserStudy extends SupabaseObjectFunctions implements SupabaseObject {
  @override
  String tableName = 'user_study';
  @override
  String id;
  String studyId;
  String userId;
  String title;
  Contact contact;
  String description;
  String iconName;
  DateTime startDate;
  StudySchedule schedule;
  List<String> interventionOrder;
  InterventionSet interventionSet;
  List<Observation> observations;
  List<ConsentItem> consent;
  Map<String, List<Result>> results;
  ReportSpecification reportSpecification;

  fhir.Questionnaire fhirQuestionnaire;

  UserStudy();

  factory UserStudy.fromJson(Map<String, dynamic> json) => UserStudy()
    ..id = json['id'] as String
    ..studyId = json['study_id'] as String
    ..userId = json['user_id'] as String
    ..title = json['title'] as String
    ..description = json['description'] as String
    ..contact = Contact.fromJson(json['contact'] as Map<String, dynamic>)
    ..iconName = json['icon_name'] as String
    ..startDate = DateTime.tryParse(json['start_date'] as String)
    ..consent = (json['consent'] as List).map((e) => ConsentItem.fromJson(e as Map<String, dynamic>)).toList()
    ..interventionSet = InterventionSet.fromJson(json['intervention_set'] as Map<String, dynamic>)
    ..interventionOrder = List<String>.from(json['intervention_order_ids'] as List)
    ..observations = (json['observations'] as List).map((e) => Observation.fromJson(e as Map<String, dynamic>)).toList()
    ..schedule = StudySchedule.fromJson(json['schedule'] as Map<String, dynamic>)
    ..reportSpecification = json['report_specification'] != null
        ? ReportSpecification.fromJson(json['report_specification'] as Map<String, dynamic>)
        : null
    ..results = (json['results'] as Map<String, dynamic>)?.map<String, List<Result>>((key, resultsData) {
          final results = (resultsData as List)
              .map<Result>((resultData) => Result.fromJson(resultData as Map<String, dynamic>))
              .toList();
          return MapEntry(key, results);
        }) ??
        {};

  @override
  Map<String, dynamic> toJson() => <String, dynamic>{
        'id': id,
        'study_id': studyId,
        'user_id': userId,
        'title': title,
        'description': description,
        'contact': contact.toJson(),
        'icon_name': iconName,
        'start_date': startDate.toIso8601String(),
        'consent': consent.map((e) => e.toJson()).toList(),
        'intervention_set': interventionSet.toJson(),
        'intervention_order_ids': interventionOrder,
        'observations': observations.map((e) => e.toJson()).toList(),
        'schedule': schedule.toJson(),
        'report_specification': reportSpecification?.toJson(),
        'results': results?.map<String, dynamic>(
                (key, value) => MapEntry(key, value.map((result) => result.toJson()).toList())) ??
            {},
        // Some values could be null (id), therefore remove all null values
      }..removeWhere((key, value) => value == null);

  int get daysPerIntervention => schedule.numberOfCycles * schedule.phaseDuration;

  void addResult(Result result) {
    final nextResults = results;
    nextResults.putIfAbsent(result.taskId, () => []).add(result);
    results = nextResults;
  }

  void addResults(List<Result> newResults) {
    if (newResults.isEmpty) return;
    final nextResults = results;
    for (final result in newResults) {
      nextResults.putIfAbsent(result.taskId, () => []).add(result);
    }
    results = nextResults;
  }

  Map<String, List<Result>> getResultsByInterventionId({String taskId}) {
    final resultMap = <String, List<Result>>{};
    results.values
        .map((value) => value.where((result) => taskId == null || taskId == result.taskId).map((result) {
              final intervention = getInterventionForDate(result.timeStamp);
              return intervention != null ? MapEntry(intervention.id, result) : null;
            }))
        .expand((element) => element)
        .where((element) => element != null)
        .forEach((element) => resultMap.putIfAbsent(element.key, () => []).add(element.value));
    return resultMap;
  }

  Map<DateTime, List<Result>> getResultsByDate({String interventionId}) {
    final resultMap = <DateTime, List<Result>>{};
    results.values
        .map((value) => value.map((result) {
              final intervention = getInterventionForDate(result.timeStamp);
              return intervention.id == interventionId
                  ? MapEntry(DateTime(result.timeStamp.year, result.timeStamp.month, result.timeStamp.day), result)
                  : null;
            }))
        .expand((element) => element)
        .where((element) => element != null)
        .forEach((element) => resultMap.putIfAbsent(element.key, () => []).add(element.value));
    return resultMap;
  }

  // Day after last intervention
  DateTime get endDate => startDate.add(Duration(days: interventionOrder.length * schedule.phaseDuration));

  int getDayOfStudyFor(DateTime date) {
    final day = date.differenceInDays(startDate).inDays;
    return day;
  }

  int getInterventionIndexForDate(DateTime date) {
    final test = date.differenceInDays(startDate).inDays;
    return test ~/ schedule.phaseDuration;
  }

  Intervention getInterventionForDate(DateTime date) {
    final index = getInterventionIndexForDate(date);
    if (index < 0 || index >= interventionOrder.length) {
      print('Study is over or has not begun.');
      return null;
    }
    final interventionId = interventionOrder[index];
    return interventionSet.interventions
        .firstWhere((intervention) => intervention.id == interventionId, orElse: () => null);
  }

  List<Intervention> getInterventionsInOrder() {
    return interventionOrder
        .map((key) => interventionSet.interventions.firstWhere((intervention) => intervention.id == key))
        .toList();
  }

  DateTime startOfPhase(int index) => startDate.add(Duration(days: schedule.phaseDuration * index));

  DateTime dayAfterEndOfPhase(int index) => startOfPhase(index).add(Duration(days: schedule.phaseDuration));

  List<Result> resultsFor(String taskId) => results[taskId];

  Map<String, int> completedPerTaskForPhase(int index) =>
      resultsForPhase(index).map((taskId, taskResults) => MapEntry(taskId, taskResults.length));

  Map<String, List<Result>> resultsForPhase(int index) {
    return resultsBetween(startOfPhase(index).subtract(const Duration(days: 1)), dayAfterEndOfPhase(index));
  }

  // Excluding start and end
  Map<String, List<Result>> resultsBetween(DateTime start, DateTime end) {
    return results.map((taskId, taskResults) => MapEntry(taskId,
        taskResults.where((result) => result.timeStamp.isBefore(end) && result.timeStamp.isAfter(start)).toList()));
  }

  int completedForPhase(int index) {
    final start = startOfPhase(index);
    int completedCount = 0;
    for (int i = 0; i < schedule.phaseDuration; i++) {
      if (allTasksCompletedFor(start.add(Duration(days: i)))) {
        completedCount++;
      }
    }
    return completedCount;
  }

  double percentCompletedForPhase(int index) {
    return completedForPhase(index) / schedule.phaseDuration;
  }

  double percentMissedForPhase(int index, DateTime date) {
    if (startOfPhase(index).isAfter(date)) return 0;

    final missedInPhase =
        min(date.differenceInDays(startOfPhase(index)).inDays, schedule.phaseDuration) - completedForPhase(index);
    return missedInPhase / schedule.phaseDuration;
  }

  // TODO: Add index to support same task multiple times per day
  bool isTaskFinishedFor(String taskId, DateTime dateTime) =>
      resultsFor(taskId)?.any((result) => result.timeStamp.isSameDate(dateTime)) ?? false;

  int completedTasksFor(Task task) {
    return resultsFor(task.id)?.length ?? 0;
  }

  // TODO: Add index to support same task multiple times per day
  bool allTasksCompletedFor(DateTime dateTime) =>
      scheduleFor(dateTime).values.every((task) => isTaskFinishedFor(task.id, dateTime));

  // Currently the end of the study, as there is no real minimum, just a set study length
  bool get minimumStudyLengthCompleted {
    final diff = DateTime.now().differenceInDays(startDate).inDays;
    return diff >= interventionOrder.length * schedule.phaseDuration - 1;
  }

  bool get completedStudy {
    return minimumStudyLengthCompleted && allTasksCompletedFor(DateTime.now());
  }

  int totalTaskCountFor(Task task) {
    var daysCount = daysPerIntervention;

    if (task is Observation) {
      daysCount = 2 * daysCount + (schedule.includeBaseline ? schedule.phaseDuration : 0);
    }

    return daysCount * task.schedule.length;
  }

  Multimap<Time, Task> scheduleFor(DateTime dateTime) {
    final activeIntervention = getInterventionForDate(dateTime);

    final taskSchedule = Multimap<Time, Task>();

    if (activeIntervention == null) return taskSchedule;

    for (final task in activeIntervention.tasks) {
      for (final schedule in task.schedule) {
        if (schedule is FixedSchedule) {
          taskSchedule.add(schedule.time, task);
        }
      }
    }
    for (final observation in observations) {
      for (final schedule in observation.schedule) {
        if (schedule is FixedSchedule) {
          taskSchedule.add(schedule.time, observation);
        }
      }
    }
    return taskSchedule;
  }

  void setStartDateBackBy({int days}) {
    startDate = startDate.subtract(Duration(days: days));
    results = results.map((task, results) => MapEntry(
        task,
        results.map((result) {
          final json = result.toJson();
          json['timeStamp'] = result.timeStamp.subtract(Duration(days: days)).toString();
          return Result.fromJson(json);
        }).toList()));
    save();
  }

  Future<PostgrestResponse> getUserStudiesFor(Study study) async =>
      client.from('study').select().eq('study_id', study.id).execute();

  Future<UserStudy> getUserStudy(String id) async =>
      UserStudy.fromJson(((await getById(id)).data as List).first as Map<String, dynamic>); // TODO: Add error checking

  Future<UserStudy> saveUserStudy() async {
    final response = await save();
    if (response.error != null) {
      print('Error: ${response.error.message}');
      // ignore: only_throw_errors
      throw response.error;
    }
    return UserStudy.fromJson((response.data as List).first as Map<String, dynamic>);
  }

  Future<PostgrestResponse> getStudyHistory(String userId) async =>
      client.from('user_study').select().eq('user_id', userId).execute();
}
