import 'dart:math';

import 'package:collection/collection.dart' show IterableExtension;
import 'package:fhir/r4.dart' as fhir;
import 'package:json_annotation/json_annotation.dart';
import 'package:quiver/collection.dart';
import 'package:uuid/uuid.dart';

import '../../env/env.dart' as env;
import '../../util/extensions.dart';
import '../../util/supabase_object.dart';
import '../models.dart';

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
  DateTime? startedAt;
  @JsonKey(name: 'selected_intervention_ids')
  List<String> selectedInterventionIds;
  @JsonKey(name: 'invite_code')
  String? inviteCode;

  @JsonKey(ignore: true)
  late Study study;

  @JsonKey(ignore: true)
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
      subject.progress = progress
          .map((json) => SubjectProgress.fromJson(json as Map<String, dynamic>))
          .toList();
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

  Future<void> addResult<T>({required String taskId, required T result}) async {
    late final Result<T> resultObject;
    print('Debug: addResult2: $result');
    switch (T) {
      case QuestionnaireState:
        resultObject = Result<T>.app(type: 'QuestionnaireState', result: result);
        break;
      case fhir.QuestionnaireResponse:
        resultObject = Result<T>.app(type: 'fhir.QuestionnaireResponse', result: result);
        break;
      case bool:
        resultObject = Result<T>.app(type: 'bool', result: result);
        break;
      default:
        print('Unsupported question type: $T');
        resultObject = Result<T>.app(type: 'unknown', result: result);
    }
    print('Debug: subjectId: ${id}');
    print('Debug: interventionId: ${getInterventionForDate(DateTime.now())!.id}');
    print('Debug: resultObject: ${resultObject.type} $resultObject');
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
    final day = date.differenceInDays(startedAt!).inDays;
    return day;
  }

  int getInterventionIndexForDate(DateTime date) {
    final test = date.differenceInDays(startedAt!).inDays;
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
    final startDate = DateTime(start.year, start.month, start.day);
    return study.schedule.phaseDuration - DateTime.now().differenceInDays(startDate).inDays;
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
      resultsFor(taskId).any((p) => p.completedAt!.isSameDate(dateTime));

  int completedTasksFor(Task task) => resultsFor(task.id).length;

  // TODO: Add index to support same task multiple times per day
  bool allTasksCompletedFor(DateTime dateTime) =>
      scheduleFor(dateTime).values.every((task) => isTaskFinishedFor(task.id, dateTime));

  // Currently the end of the study, as there is no real minimum, just a set study length
  bool get minimumStudyLengthCompleted {
    final diff = DateTime.now().differenceInDays(startedAt!).inDays;
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

  Multimap<CompletionPeriod, Task> scheduleFor(DateTime dateTime) {
    final activeIntervention = getInterventionForDate(dateTime);

    final Multimap<CompletionPeriod, Task> taskSchedule = Multimap<CompletionPeriod, Task>();

    if (activeIntervention == null) return taskSchedule;

    for (final task in activeIntervention.tasks) {
      for (final completionPeriod in task.schedule.completionPeriods) {
        taskSchedule.add(completionPeriod, task);
      }
    }
    for (final observation in study.observations) {
      for (final completionPeriod in observation.schedule.completionPeriods) {
        taskSchedule.add(completionPeriod, observation);
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
    final response = await env.client.from(tableName).upsert(toJson()).execute();

    SupabaseQuery.catchPostgrestError(response);
    final json = List<Map<String, dynamic>>.from(response.data as List).single;
    json['study'] = study.toJson();
    json['subject_progress'] = progress.map((p) => p.toJson()).toList();
    return StudySubject.fromJson(json);
  }

  Future<void> deleteProgress() async => SupabaseQuery.catchPostgrestError(
        await env.client.from(SubjectProgress.tableName).delete().eq('subject_id', id).execute(),
      );

  @override
  Future<StudySubject> delete() async {
    await deleteProgress();
    final response = await env.client.from(tableName).delete().eq('id', id).single().execute();

    SupabaseQuery.catchPostgrestError(response);
    final json = response.data as Map<String, dynamic>;
    json['study'] = study.toJson();
    return StudySubject.fromJson(json);
  }

  static Future<List<StudySubject>> getUserStudiesFor(Study study) async =>
      SupabaseQuery.extractSupabaseList<StudySubject>(
        await env.client
            .from(tableName)
            .select('*,study!study_subject_studyId_fkey(*),subject_progress(*)')
            .eq('study_id', study.id)
            .execute(),
      );

  static Future<List<StudySubject>> getStudyHistory(String userId) async {
    return SupabaseQuery.extractSupabaseList<StudySubject>(
      await env.client
          .from(tableName)
          .select('*,study!study_subject_studyId_fkey(*),subject_progress(*)')
          .eq('user_id', userId)
          .execute(),
    );
  }
}
