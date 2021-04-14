import 'dart:math';

import 'package:collection/collection.dart' show IterableExtension;
import 'package:json_annotation/json_annotation.dart';
import 'package:quiver/collection.dart';

import '../../env/env.dart';
import '../../util/extensions.dart';
import '../../util/supabase_object.dart';
import '../models.dart';

part 'user_study.g.dart';

@JsonSerializable()
class UserStudy extends SupabaseObjectFunctions<UserStudy> {
  static const String tableName = 'user_study';

  // Needs late to use the fromJson initializer
  @override
  String? id;
  late String studyId;
  late String userId;
  late DateTime startDate;
  late List<String> selectedInterventionIds;
  late Map<String, List<Result>> results = {};

  @JsonKey(ignore: true)
  late Study study;

  UserStudy();

  factory UserStudy.fromJson(Map<String, dynamic> json) =>
      _$UserStudyFromJson(json)..study = Study.fromJson(json['study'] as Map<String, dynamic>);

  @override
  Map<String, dynamic> toJson() => _$UserStudyToJson(this);

  UserStudy.fromStudy(this.study, this.userId, this.selectedInterventionIds) : studyId = study.id!;

  List<String> get interventionOrder => [
        if (study.schedule.includeBaseline) Study.baselineID,
        ...study.schedule.generateWith(0).map<String>((int index) => selectedInterventionIds[index])
      ];

  List<Intervention> get selectedInterventions {
    final selectedInterventions = selectedInterventionIds
        .map((selectedInterventionId) =>
            study.interventions.singleWhere((intervention) => intervention.id == selectedInterventionId))
        .toList();
    if (study.schedule.includeBaseline) {
      selectedInterventions.add(Intervention(Study.baselineID, 'Baseline')
        ..tasks = []
        ..icon = 'rayStart');
    }
    return selectedInterventions;
  }

  int get daysPerIntervention => study.schedule.numberOfCycles * study.schedule.phaseDuration;

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

  Map<String, List<Result>> getResultsByInterventionId({required String taskId}) {
    final resultMap = <String, List<Result>>{};
    results.values
        .map((value) => value.where((result) => taskId == result.taskId).map((result) {
              final intervention = getInterventionForDate(result.timeStamp);
              return intervention != null ? MapEntry(intervention.id, result) : null;
            }))
        .expand((element) => element)
        .where((element) => element != null)
        .forEach((element) => resultMap.putIfAbsent(element!.key, () => []).add(element.value));
    return resultMap;
  }

  Map<DateTime, List<Result>> getResultsByDate({required String interventionId}) {
    final resultMap = <DateTime, List<Result>>{};
    results.values
        .map((value) => value.map((result) {
              final intervention = getInterventionForDate(result.timeStamp)!;
              return intervention.id == interventionId
                  ? MapEntry(DateTime(result.timeStamp.year, result.timeStamp.month, result.timeStamp.day), result)
                  : null;
            }))
        .expand((element) => element)
        .where((element) => element != null)
        .forEach((element) => resultMap.putIfAbsent(element!.key, () => []).add(element.value));
    return resultMap;
  }

  // Day after last intervention
  DateTime get endDate => startDate.add(Duration(days: interventionOrder.length * study.schedule.phaseDuration));

  int getDayOfStudyFor(DateTime date) {
    final day = date.differenceInDays(startDate).inDays;
    return day;
  }

  int getInterventionIndexForDate(DateTime date) {
    final test = date.differenceInDays(startDate).inDays;
    return test ~/ study.schedule.phaseDuration;
  }

  Intervention? getInterventionForDate(DateTime date) {
    final index = getInterventionIndexForDate(date);
    if (index < 0 || index >= interventionOrder.length) {
      print('Study is over or has not begun.');
      return null;
    }
    final interventionId = interventionOrder[index];
    return selectedInterventions.firstWhereOrNull((intervention) => intervention.id == interventionId);
  }

  List<Intervention> getInterventionsInOrder() {
    return interventionOrder
        .map((key) => selectedInterventions.firstWhere((intervention) => intervention.id == key))
        .toList();
  }

  DateTime startOfPhase(int index) => startDate.add(Duration(days: study.schedule.phaseDuration * index));

  DateTime dayAfterEndOfPhase(int index) => startOfPhase(index).add(Duration(days: study.schedule.phaseDuration));

  List<Result>? resultsFor(String taskId) => results[taskId];

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
    for (int i = 0; i < study.schedule.phaseDuration; i++) {
      if (allTasksCompletedFor(start.add(Duration(days: i)))) {
        completedCount++;
      }
    }
    return completedCount;
  }

  double percentCompletedForPhase(int index) {
    return completedForPhase(index) / study.schedule.phaseDuration;
  }

  double percentMissedForPhase(int index, DateTime date) {
    if (startOfPhase(index).isAfter(date)) return 0;

    final missedInPhase =
        min(date.differenceInDays(startOfPhase(index)).inDays, study.schedule.phaseDuration) - completedForPhase(index);
    return missedInPhase / study.schedule.phaseDuration;
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
    return diff >= interventionOrder.length * study.schedule.phaseDuration - 1;
  }

  bool get completedStudy {
    return minimumStudyLengthCompleted && allTasksCompletedFor(DateTime.now());
  }

  int totalTaskCountFor(Task task) {
    var daysCount = daysPerIntervention;

    if (task is Observation) {
      daysCount = 2 * daysCount + (study.schedule.includeBaseline ? study.schedule.phaseDuration : 0);
    }

    return daysCount * task.schedule.length;
  }

  Multimap<ScheduleTime, Task> scheduleFor(DateTime dateTime) {
    final activeIntervention = getInterventionForDate(dateTime);

    final Multimap<ScheduleTime?, Task> taskSchedule = Multimap<ScheduleTime, Task>();

    if (activeIntervention == null) return taskSchedule as Multimap<ScheduleTime, Task>;

    for (final task in activeIntervention.tasks) {
      for (final schedule in task.schedule) {
        if (schedule is FixedSchedule) {
          taskSchedule.add(schedule.time, task);
        }
      }
    }
    for (final observation in study.observations) {
      for (final schedule in observation.schedule) {
        if (schedule is FixedSchedule) {
          taskSchedule.add(schedule.time, observation);
        }
      }
    }
    return taskSchedule as Multimap<ScheduleTime, Task>;
  }

  void setStartDateBackBy({required int days}) {
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

  @override
  Future<UserStudy> save() async {
    final response = await client.from(tableName).insert(toJson(), upsert: true).execute();

    SupabaseQuery.catchPostgrestError(response.error);
    final json = List<Map<String, dynamic>>.from(response.data as List).single;
    json['study'] = study.toJson();
    return UserStudy.fromJson(json);
  }

  @override
  Future<UserStudy> delete() async {
    final response = await client.from(tableName).delete().eq('id', id).single().execute();

    SupabaseQuery.catchPostgrestError(response.error);
    final json = response.data as Map<String, dynamic>;
    json['study'] = study.toJson();
    return UserStudy.fromJson(json);
  }

  static Future<List<UserStudy>> getUserStudiesFor(Study study) async => SupabaseQuery.extractSupabaseList<UserStudy>(
      await client.from(tableName).select().eq('studyId', study.id).execute());

  static Future<List<UserStudy>> getStudyHistory(String userId) async => SupabaseQuery.extractSupabaseList<UserStudy>(
      await client.from(tableName).select().eq('userId', userId).execute());
}
