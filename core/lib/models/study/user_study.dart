import 'dart:math';

import 'package:quiver/collection.dart';

import '../../util/extensions.dart';
import '../models.dart';

class UserStudyBase {
  String studyId;
  String userId;
  String title;
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
}

extension UserStudyExtension on UserStudyBase {
  UserStudyBase toBase() {
    return UserStudyBase()
      ..studyId = studyId
      ..userId = userId
      ..title = title
      ..description = description
      ..iconName = iconName
      ..startDate = startDate
      ..schedule = schedule
      ..interventionOrder = interventionOrder
      ..interventionSet = interventionSet
      ..observations = observations
      ..consent = consent
      ..results = results
      ..reportSpecification = reportSpecification;
  }

  int get daysPerIntervention => schedule.numberOfCycles * schedule.phaseDuration;

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
      resultsForPhase(index).map(((taskId, taskResults) => MapEntry(taskId, taskResults.length)));

  Map<String, List<Result>> resultsForPhase(int index) {
    return resultsBetween(startOfPhase(index).subtract(Duration(days: 1)), dayAfterEndOfPhase(index));
  }

  // Excluding start and end
  Map<String, List<Result>> resultsBetween(DateTime start, DateTime end) {
    return results.map((taskId, taskResults) => MapEntry(
        taskId, taskResults.where((result) => result.timeStamp.isBefore(end) && result.timeStamp.isAfter(start))));
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
    var diff = DateTime.now().differenceInDays(startDate).inDays;
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
}
