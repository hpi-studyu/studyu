import 'dart:math';

import 'package:collection/collection.dart' show IterableExtension;
import 'package:fhir/r4.dart' as fhir;
import 'package:json_annotation/json_annotation.dart';
import 'package:studyu_core/src/env/env.dart' as env;
import 'package:studyu_core/src/models/models.dart';
import 'package:studyu_core/src/util/extensions.dart';
import 'package:studyu_core/src/util/supabase_object.dart';
import 'package:uuid/uuid.dart';

part 'study_subject.g.dart';

@JsonSerializable()
class StudySubject extends SupabaseObjectFunctions<StudySubject> {
  static const String tableName = 'study_subject';

  @override
  Map<String, dynamic> get primaryKeys => {'id': id};

  String id;
  @JsonKey(name: 'study_id')
  String studyId;
  @JsonKey(name: 'user_id')
  String userId;
  @JsonKey(name: 'started_at')
  // stored in UTC format, be careful when comparing dates
  DateTime? startedAt;
  @JsonKey(name: 'selected_intervention_ids')
  List<String> selectedInterventionIds;
  @JsonKey(name: 'invite_code')
  String? inviteCode;
  @JsonKey(name: 'is_deleted')
  bool isDeleted = false;

  @JsonKey(includeToJson: false, includeFromJson: false)
  late Study study;

  @JsonKey(includeToJson: false, includeFromJson: false)
  late List<SubjectProgress> progress = [];

  StudySubject(this.id, this.studyId, this.userId, this.selectedInterventionIds);

  factory StudySubject.fromJson(Map<String, dynamic> json) {
    final subject = _$StudySubjectFromJson(json);

    final Map<String, dynamic>? study = json['study'] as Map<String, dynamic>?;
    if (study != null) {
      subject.study = Study.fromJson(study);
    }

    final List? progress = json['subject_progress'] as List?;
    if (progress != null) {
      subject.progress = progress.map((json) => SubjectProgress.fromJson(json as Map<String, dynamic>)).toList();
    }

    return subject;
  }

  @override
  Map<String, dynamic> toJson() => _$StudySubjectToJson(this);

  StudySubject.fromStudy(this.study, this.userId, this.selectedInterventionIds, this.inviteCode)
      : id = const Uuid().v4(),
        studyId = study.id;

  List<String> get interventionOrder => [
        if (study.schedule.includeBaseline) Study.baselineID,
        ...study.schedule.generateWith(0).map<String>((int index) => selectedInterventionIds[index])
      ];

  List<Intervention> get selectedInterventions {
    final selectedInterventions = selectedInterventionIds
        .map(
          (selectedInterventionId) =>
              study.interventions.singleWhere((intervention) => intervention.id == selectedInterventionId),
        )
        .toList();
    if (study.schedule.includeBaseline) {
      selectedInterventions.add(
        Intervention(Study.baselineID, 'Baseline')
          ..tasks = []
          ..icon = 'rayStart',
      );
    }
    return selectedInterventions;
  }

  int get daysPerIntervention => study.schedule.numberOfCycles * study.schedule.phaseDuration;

  Future<void> addResult<T>({required String taskId, required String periodId, required T result}) async {
    late final Result<T> resultObject;
    switch (T) {
      case QuestionnaireState:
        resultObject = Result<T>.app(type: 'QuestionnaireState', periodId: periodId, result: result);
        break;
      case fhir.QuestionnaireResponse:
        resultObject = Result<T>.app(type: 'fhir.QuestionnaireResponse', periodId: periodId, result: result);
        break;
      case bool:
        resultObject = Result<T>.app(type: 'bool', periodId: periodId, result: result);
        break;
      default:
        print('Unsupported question type: $T');
        resultObject = Result<T>.app(type: 'unknown', periodId: periodId, result: result);
    }

    final p = await SubjectProgress(
      subjectId: id,
      interventionId: getInterventionForDate(DateTime.now())!.id,
      taskId: taskId,
      result: resultObject,
      resultType: resultObject.type,
    ).save();
    progress.add(p);
    await save();
  }

  Map<DateTime, List<SubjectProgress>> getResultsByDate({required String interventionId}) {
    final resultsByDate = <DateTime, List<SubjectProgress>>{};
    progress.where((p) => p.interventionId == interventionId).forEach((p) {
      final date = DateTime(p.completedAt!.year, p.completedAt!.month, p.completedAt!.day);
      resultsByDate.putIfAbsent(date, () => []);
      resultsByDate[date]!.add(p);
    });
    return resultsByDate;
  }

  // Day after last intervention
  DateTime endDate(DateTime dt) => dt.add(Duration(days: interventionOrder.length * study.schedule.phaseDuration));

  int getDayOfStudyFor(DateTime date) {
    return date.differenceInDays(startedAt!);
  }

  int getInterventionIndexForDate(DateTime date) {
    final test = date.differenceInDays(startedAt!);
    return test ~/ study.schedule.phaseDuration;
  }

  Intervention? getInterventionForDate(DateTime date) {
    final index = getInterventionIndexForDate(date);
    if (startedAt!.isAfter(DateTime.now()) || index >= interventionOrder.length) {
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

  DateTime startOfPhase(int index) => startedAt!.add(Duration(days: study.schedule.phaseDuration * index));

  DateTime dayAfterEndOfPhase(int index) => startOfPhase(index).add(Duration(days: study.schedule.phaseDuration));

  List<SubjectProgress> resultsFor(String taskId) => progress.where((p) => p.taskId == taskId).toList();

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

  int daysLeftForPhase(int index) {
    final start = startOfPhase(index);
    return study.schedule.phaseDuration - DateTime.now().differenceInDays(start);
  }

  double percentCompletedForPhase(int index) {
    return completedForPhase(index) / study.schedule.phaseDuration;
  }

  double percentMissedForPhase(int index, DateTime date) {
    if (startOfPhase(index).isAfter(date)) return 0;

    final missedInPhase =
        min(date.differenceInDays(startOfPhase(index)), study.schedule.phaseDuration) - completedForPhase(index);
    return missedInPhase / study.schedule.phaseDuration;
  }

  List<SubjectProgress> getTaskProgressForDay(String taskId, DateTime dateTime) {
    final List<SubjectProgress> thisTaskProgressToday = [];
    for (final SubjectProgress sp in resultsFor(taskId)) {
      if (sp.subjectId == id && sp.completedAt!.isSameDate(dateTime)) {
        thisTaskProgressToday.add(sp);
      }
    }
    return thisTaskProgressToday;
  }

  /// Check if a task instance is completed
  /// returns true if a given task has been completed for a specific
  /// completionPeriod on a given day
  bool completedTaskInstanceForDay(String taskId, CompletionPeriod completionPeriod, DateTime dateTime) {
    return getTaskProgressForDay(taskId, dateTime).any(
      (progress) {
        if (progress.result.periodId == null) {
          // fallback to support studies without periodIds
          return progress.completedAt!.isSameDate(dateTime);
        }
        return progress.result.periodId == completionPeriod.id;
      },
    );
  }

  /// Check if a task is fully completed for all task instances
  /// returns true if a given task has been completed for all of its
  /// completionPeriods on a given day
  bool completedTaskForDay(String taskId, DateTime dateTime) {
    return [...selectedInterventions.expand((e) => e.tasks), ...study.observations]
        .where((task) => task.id == taskId)
        .single
        .schedule
        .completionPeriods
        .any(
          (period) => completedTaskInstanceForDay(taskId, period, dateTime),
        );
  }

  int completedTasksFor(Task task) => resultsFor(task.id).length;

  /// Check if all tasks are fully completed on a given day
  /// returns true if all of of the tasks (interventions & observations)
  /// have been completed on a given day
  bool allTasksCompletedFor(DateTime dateTime) => scheduleFor(dateTime).every(
        (taskInstance) => completedTaskForDay(taskInstance.task.id, dateTime),
      );

  // Currently the end of the study, as there is no real minimum, just a set study length
  bool get minimumStudyLengthCompleted {
    final diff = DateTime.now().differenceInDays(startedAt!);
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
    return daysCount * task.schedule.completionPeriods.length;
  }

  List<TaskInstance> scheduleFor(DateTime dateTime) {
    /* ************* WORKAROUND FIX START ***************** */
    Intervention? beforeIntervention;
    // check if study starts day after registration is already in place
    if (startedAt!.hour != 0 && startedAt!.minute != 0 && startedAt!.second != 0 && startedAt!.millisecond != 0) {
      final beforeDateTime = DateTime.utc(
          dateTime.year, dateTime.month, dateTime.day, startedAt!.hour,
          startedAt!.minute + -1,
      );
      beforeIntervention = getInterventionForDate(beforeDateTime);
      print("old subject");
      /* ************* WORKAROUND FIX END ***************** */
    } else {
      beforeIntervention = getInterventionForDate(dateTime);
      print("index: ${getInterventionIndexForDate(dateTime)}");
      print("intervention: ${beforeIntervention!.tasks}");
    }

    final List<TaskInstance> taskSchedule = [];

    if (beforeIntervention == null) return taskSchedule;

    // Workaround to display the dashboard correctly, until the trial starts
    // at the next day for every participant

    /* ************* WORKAROUND FIX START ***************** */
    // define placeholders
    bool cycleChange = false;
    DateTime afterDateTime = DateTime.now();
    Intervention? afterIntervention;

    // check if study starts day after registration is already in place
    if (startedAt!.hour != 0 && startedAt!.minute != 0 && startedAt!.second != 0 && startedAt!.millisecond != 0) {
      afterDateTime = DateTime.utc(
          dateTime.year, dateTime.month, dateTime.day, startedAt!.hour,
          startedAt!.minute + 1,
      );
      afterIntervention = getInterventionForDate(afterDateTime);

      if (afterIntervention == null) return taskSchedule;

      // there is a cycle change during the day, i.e. the interventions change
      cycleChange = afterIntervention != beforeIntervention;
      print("old subject. cyclechange $cycleChange");
    }

    /* ************* WORKAROUND FIX END ***************** */

    for (final task in beforeIntervention.tasks) {
      if (task.title == null) continue;

      for (final completionPeriod in task.schedule.completionPeriods) {
        /* ************* WORKAROUND FIX START ***************** */
        if (cycleChange) {
          final lockTime = DateTime(
            afterDateTime.year, afterDateTime.month, afterDateTime.day,
            completionPeriod.lockTime.hour, completionPeriod.lockTime.minute,
          );
          if (lockTime.isBefore(dateTime)) {
            taskSchedule.add(TaskInstance(task, completionPeriod.id));
          }
        } else {
          /* ************* WORKAROUND FIX END ***************** */
          taskSchedule.add(TaskInstance(task, completionPeriod.id));
        }
      }
    }
    /* ************* WORKAROUND FIX START ***************** */
    if (cycleChange) {
      for (final task in afterIntervention!.tasks) {
        if (task.title == null) continue;

        for (final completionPeriod in task.schedule.completionPeriods) {
          final openTime = DateTime(
            afterDateTime.year, afterDateTime.month, afterDateTime.day,
            completionPeriod.unlockTime.hour, completionPeriod.unlockTime.minute,
          );
          if (openTime.isAfter(dateTime)) {
            taskSchedule.add(TaskInstance(task, completionPeriod.id));
          }
        }
      }
    }
    /* ************* WORKAROUND FIX END ***************** */
    for (final observation in study.observations) {
      for (final completionPeriod in observation.schedule.completionPeriods) {
        taskSchedule.add(TaskInstance(observation, completionPeriod.id));
      }
    }
    return taskSchedule;
  }

  Future<void> setStartDateBackBy({required int days}) async {
    await deleteProgress();
    progress = await SupabaseQuery.batchUpsert(progress.map((p) => p.setStartDateBackBy(days: days).toJson()).toList());
    startedAt = startedAt!.subtract(Duration(days: days));
    save();
  }

  @override
  Future<StudySubject> save() async {
    try {
      final response = await env.client.from(tableName).upsert(toJson()).select<List>();
      final json = List<Map<String, dynamic>>.from(response).single;
      json['study'] = study.toJson();
      json['subject_progress'] = progress.map((p) => p.toJson()).toList();
      return StudySubject.fromJson(json);
    } catch (e, stack) {
      SupabaseQuery.catchSupabaseException(e, stack);
      rethrow;
    }
  }

  Future<void> deleteProgress() async {
    try {
      await env.client.from(SubjectProgress.tableName).delete().eq('subject_id', id);
    } catch (error, stacktrace) {
      SupabaseQuery.catchSupabaseException(error, stacktrace);
      rethrow;
    }
  }

  @override
  Future<StudySubject> delete() async {
    await deleteProgress();
    try {
      final response = await env.client.from(tableName).delete().eq('id', id).single().select<Map<String, dynamic>>();
      response['study'] = study.toJson();
      return StudySubject.fromJson(response);
    } catch (error, stacktrace) {
      SupabaseQuery.catchSupabaseException(error, stacktrace);
      rethrow;
    }
  }

  Future<StudySubject> softDelete() {
    isDeleted = true;
    return save();
  }

  static Future<List<StudySubject>> getStudyHistory(String userId) async {
    return SupabaseQuery.extractSupabaseList<StudySubject>(
      await env.client.from(tableName).select('*,study!study_subject_studyId_fkey(*),subject_progress(*)'),
    );
  }

  @override
  String toString() {
    return 'StudySubject{id: $id, studyId: $studyId, userId: $userId, startedAt: $startedAt, selectedInterventionIds: $selectedInterventionIds, inviteCode: $inviteCode, isDeleted: $isDeleted, study: $study, progress: $progress}';
  }
}
