import 'package:parse_server_sdk/parse_server_sdk.dart';
import 'package:quiver/collection.dart';

import '../../util/extensions.dart';
import '../models.dart';

class ParseUserStudy extends ParseObject implements ParseCloneable {
  static const _keyTableName = 'UserStudy';

  ParseUserStudy() : super(_keyTableName);

  ParseUserStudy.clone() : this();

  @override
  ParseUserStudy clone(Map<String, dynamic> map) => ParseUserStudy.clone()..fromJson(map);

  static const keyStudyId = 'study_id';
  String get studyId => get<String>(keyStudyId);
  set studyId(String studyId) => set<String>(keyStudyId, studyId);

  static const keyUserId = 'user_id';
  String get userId => get<String>(keyUserId);
  set userId(String userId) => set<String>(keyUserId, userId);

  static const keyTitle = 'title';
  String get title => get<String>(keyTitle);
  set title(String title) => set<String>(keyTitle, title);

  static const keyDescription = 'description';
  String get description => get<String>(keyDescription);
  set description(String description) => set<String>(keyDescription, description);

  static const keyIconName = 'icon_name';
  String get iconName => get<String>(keyIconName);
  set iconName(String iconName) => set<String>(keyIconName, iconName);

  static const keyStartDate = 'start_date';
  DateTime get startDate => get<DateTime>(keyStartDate);
  set startDate(DateTime startDate) => set<DateTime>(keyStartDate, startDate);

  static const keySchedule = 'schedule';
  StudySchedule get schedule => StudySchedule.fromJson(get<Map<String, dynamic>>(keySchedule));
  set schedule(StudySchedule schedule) => set<Map<String, dynamic>>(keySchedule, schedule.toJson());

  static const keyInterventionOrder = 'intervention_order_ids';
  List<String> get interventionOrder => get<List<dynamic>>(keyInterventionOrder).map<String>((e) => e).toList();
  set interventionOrder(List<String> interventionOrder) => set<List<String>>(keyInterventionOrder, interventionOrder);

  static const keyInterventionSet = 'intervention_set';
  InterventionSet get interventionSet => InterventionSet.fromJson(get<Map<String, dynamic>>(keyInterventionSet));
  set interventionSet(InterventionSet interventionSet) =>
      set<Map<String, dynamic>>(keyInterventionSet, interventionSet.toJson());

  static const keyObservations = 'observations';
  List<Observation> get observations =>
      get<List<dynamic>>(keyObservations)?.map((e) => Observation.fromJson(e))?.toList() ?? [];
  set observations(List<Observation> observations) =>
      set<List<dynamic>>(keyObservations, observations.map((e) => e.toJson()).toList());

  static const keyConsent = 'consent';
  List<ConsentItem> get consent =>
      get<List<dynamic>>(keyConsent, defaultValue: []).map((e) => ConsentItem.fromJson(e)).toList();
  set consent(List<ConsentItem> consent) => set<List<dynamic>>(keyConsent, consent.map((e) => e.toJson()).toList());

  static const keyResults = 'results';
  Map<String, List<Result>> get results =>
      get<Map<String, dynamic>>(keyResults, defaultValue: {}).map<String, List<Result>>((key, resultsData) =>
          MapEntry(key, resultsData.map<Result>((resultData) => Result.fromJson(resultData)).toList()));
  set results(Map<String, List<Result>> results) => set<Map<String, dynamic>>(keyResults,
      results.map<String, dynamic>((key, value) => MapEntry(key, value.map((result) => result.toJson()).toList())));

  static const keyReportSpecification = 'report_specification';
  ReportSpecification get reportSpecification =>
      ReportSpecification.fromJson(get<Map<String, dynamic>>(keyReportSpecification));
  set reportSpecification(ReportSpecification reportSpecification) =>
      set<Map<String, dynamic>>(keyReportSpecification, reportSpecification.toJson());

  List<Result> resultsFor(String taskId) => results[taskId];

  bool isTaskFinishedFor(String taskId, DateTime dateTime) =>
      resultsFor(taskId)?.any((result) => result.timeStamp.day == dateTime.day) ?? false;

  void addResult(Result result) {
    var nextResults = results;
    nextResults.putIfAbsent(result.taskId, () => []).add(result);
    results = nextResults;
  }

  void addResults(List<Result> newResults) {
    if (newResults.isEmpty) return;
    var nextResults = results;
    newResults.forEach((result) => nextResults.putIfAbsent(result.taskId, () => []).add(result));
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

  int completedTasksFor(Task task) {
    return resultsFor(task.id)?.length ?? 0;
  }

  int totalTaskCountFor(Task task) {
    var daysCount = schedule.numberOfCycles * schedule.phaseDuration;

    if (task is Observation) {
      daysCount = 2 * daysCount + (schedule.includeBaseline ? schedule.phaseDuration : 0);
    }

    return daysCount * task.schedule.length;
  }

  List<Intervention> getInterventionsInOrder() {
    return interventionOrder
        .map((key) => interventionSet.interventions.firstWhere((intervention) => intervention.id == key))
        .toList();
  }

  Multimap<Time, Task> scheduleFor(DateTime dateTime) {
    final activeIntervention = getInterventionForDate(dateTime);

    final taskSchedule = Multimap<Time, Task>();
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
          result = Result.fromJson(json);
          return result;
        }).toList()));
    save();
  }
}
