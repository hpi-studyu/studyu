import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:studyu_app/screens/study/nutrition/daily_recall_entry_view_model.dart';
import 'package:studyu_app/util/nutrition_recall_autosave_manager.dart';
import 'package:studyu_core/core.dart';

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  test('add, edit, and delete cache the full recall immediately', () async {
    final prefs = await SharedPreferences.getInstance();
    final manager = NutritionRecallAutoSaveManager(preferences: prefs);
    final subject = _subject(daysAgo: 0);
    final viewModel = DailyRecallEntryViewModel(
      subject: subject,
      autoSaveManager: manager,
    );
    await Future<void>.delayed(Duration.zero);

    viewModel.addMeal(_meal('first'));
    await viewModel.flushPendingAutoSave();
    expect(
      (await manager.loadRecall(
        subjectId: subject.id,
        taskId: NutritionRecallAutoSaveManager.standaloneTaskId,
        studyDay: 0,
      ))!.meals.single.id,
      'first',
    );

    viewModel.updateMeal(0, _meal('updated'));
    await viewModel.flushPendingAutoSave();
    expect(
      (await manager.loadRecall(
        subjectId: subject.id,
        taskId: NutritionRecallAutoSaveManager.standaloneTaskId,
        studyDay: 0,
      ))!.meals.single.id,
      'updated',
    );

    viewModel.removeMeal(0);
    await viewModel.flushPendingAutoSave();
    expect(
      (await manager.loadRecall(
        subjectId: subject.id,
        taskId: NutritionRecallAutoSaveManager.standaloneTaskId,
        studyDay: 0,
      ))!.meals,
      isEmpty,
    );
    viewModel.dispose();
  });

  test('ordered writes retain the latest prepared snapshot', () async {
    final prefs = await SharedPreferences.getInstance();
    final manager = NutritionRecallAutoSaveManager(preferences: prefs);

    await Future.wait([
      _save(manager, _recall('old', studyDay: 0)),
      _save(manager, _recall('new', studyDay: 0)),
    ]);

    expect(
      (await manager.loadRecall(
        subjectId: 'subject',
        taskId: 'task',
        studyDay: 0,
      ))!.id,
      'new',
    );
  });

  test(
    'period-distinct drafts coexist and retain persistence metadata',
    () async {
      final prefs = await SharedPreferences.getInstance();
      final manager = NutritionRecallAutoSaveManager(preferences: prefs);
      final completedAt = DateTime.utc(2026, 7, 15, 12);

      await manager.saveRecall(
        recall: _recall('morning', studyDay: 3),
        subjectId: 'subject',
        taskId: 'task',
        interventionId: 'intervention-a',
        periodId: 'morning',
        studyDaySnapshot: 3,
        progressCompletedAt: completedAt,
      );
      await manager.saveRecall(
        recall: _recall('evening', studyDay: 3),
        subjectId: 'subject',
        taskId: 'task',
        interventionId: 'intervention-b',
        periodId: 'evening',
        studyDaySnapshot: 3,
      );

      expect(
        (await manager.loadRecall(
          subjectId: 'subject',
          taskId: 'task',
          periodId: 'morning',
          studyDay: 3,
        ))!.id,
        'morning',
      );
      final pending = await manager.scanPendingRecalls('subject');
      expect(pending, hasLength(2));
      expect(
        pending
            .singleWhere((recall) => recall.periodId == 'morning')
            .progressCompletedAt,
        completedAt,
      );
    },
  );

  test(
    'hydrates the current remote recall before restoring stale local data',
    () async {
      final prefs = await SharedPreferences.getInstance();
      final manager = NutritionRecallAutoSaveManager(preferences: prefs);
      final subject = _subject(daysAgo: 2);
      final task = NutritionTask.withId();
      final period = CompletionPeriod(
        id: 'period',
        unlockTime: StudyUTimeOfDay(),
        lockTime: StudyUTimeOfDay(hour: 23),
      );
      final studyDay = subject.getDayOfStudyFor(DateTime.now());
      await manager.saveRecall(
        recall: _recall('local', studyDay: studyDay),
        subjectId: subject.id,
        taskId: task.id,
        interventionId: 'intervention',
        periodId: period.id,
        studyDaySnapshot: studyDay,
      );
      final completedAt = DateTime.now()
          .add(const Duration(minutes: 1))
          .toUtc();
      subject.progress.add(
        SubjectProgress(
          subjectId: subject.id,
          interventionId: 'intervention',
          taskId: task.id,
          resultType: 'DailyRecall',
          result: Result<DailyRecall>.app(
            type: 'DailyRecall',
            periodId: period.id,
            result: _recall('remote', studyDay: studyDay),
          ),
        )..completedAt = completedAt,
      );

      final viewModel = DailyRecallEntryViewModel(
        subject: subject,
        task: task,
        completionPeriod: period,
        autoSaveManager: manager,
      );
      await Future<void>.delayed(Duration.zero);

      expect(viewModel.recall.id, 'remote');
      expect(viewModel.persistenceTarget?.completedAt, completedAt);
      viewModel.addMeal(_meal('new'));
      await viewModel.flushPendingAutoSave();
      expect(
        (await manager.scanPendingRecalls(
          subject.id,
        )).single.progressCompletedAt,
        completedAt,
      );
      viewModel.dispose();
    },
  );

  test('does not restore a cache over an edit made during loading', () async {
    final prefs = await SharedPreferences.getInstance();
    final manager = _DelayedRecallLoadManager(preferences: prefs);
    final subject = _subject(daysAgo: 2);
    final task = NutritionTask.withId();
    final period = CompletionPeriod(
      id: 'period',
      unlockTime: StudyUTimeOfDay(),
      lockTime: StudyUTimeOfDay(hour: 23),
    );
    final studyDay = subject.getDayOfStudyFor(DateTime.now());
    final viewModel = DailyRecallEntryViewModel(
      subject: subject,
      task: task,
      completionPeriod: period,
      autoSaveManager: manager,
    );
    await manager.loadStarted;

    viewModel.addMeal(_meal('edited'));
    manager.complete(
      PendingRecall(
        recall: _recall('cached', studyDay: studyDay),
        subjectId: subject.id,
        taskId: task.id,
        interventionId: 'intervention',
        periodId: period.id,
        studyDaySnapshot: studyDay,
        lastModifiedAt: DateTime.now().toIso8601String(),
        storageKey: 'cached',
      ),
    );
    await Future<void>.delayed(Duration.zero);

    expect(viewModel.recall.meals.single.id, 'edited');
    viewModel.dispose();
  });

  test('flush reports a failed local cache write', () async {
    final prefs = await SharedPreferences.getInstance();
    final manager = NutritionRecallAutoSaveManager(
      preferences: prefs,
      stringWriter: (_, _, _) async => false,
    );
    final viewModel = DailyRecallEntryViewModel(
      subject: _subject(daysAgo: 0),
      autoSaveManager: manager,
    );
    await Future<void>.delayed(Duration.zero);

    viewModel.addMeal(_meal('unsaved'));

    await expectLater(
      viewModel.flushPendingAutoSave(),
      throwsA(isA<StateError>()),
    );
    viewModel.dispose();
  });

  test('same-day upload remains incomplete and cached', () async {
    final prefs = await SharedPreferences.getInstance();
    DailyRecall? submitted;
    final manager = NutritionRecallAutoSaveManager(
      preferences: prefs,
      submitter: (_, recall) async => submitted = recall,
    );
    final subject = _subject(daysAgo: 2);
    final today = subject.getDayOfStudyFor(DateTime.now());
    await _save(manager, _recall('today', studyDay: today));

    await manager.submitPendingRecalls(subject: subject, trackProgress: true);

    expect(submitted!.entryCompletedAt, isNull);
    expect(await manager.scanPendingRecalls(subject.id), hasLength(1));
  });

  test('previous-day upload finalizes and deletes after success', () async {
    final prefs = await SharedPreferences.getInstance();
    DailyRecall? submitted;
    final manager = NutritionRecallAutoSaveManager(
      preferences: prefs,
      submitter: (_, recall) async => submitted = recall,
    );
    final subject = _subject(daysAgo: 2);
    final today = subject.getDayOfStudyFor(DateTime.now());
    await _save(manager, _recall('yesterday', studyDay: today - 1));

    await manager.submitPendingRecalls(subject: subject, trackProgress: true);

    expect(submitted!.entryCompletedAt, isNotNull);
    expect(await manager.scanPendingRecalls(subject.id), isEmpty);
  });

  test(
    'historical correction keeps its existing completion metadata',
    () async {
      final prefs = await SharedPreferences.getInstance();
      DailyRecall? submitted;
      final manager = NutritionRecallAutoSaveManager(
        preferences: prefs,
        submitter: (_, recall) async => submitted = recall,
      );
      final subject = _subject(daysAgo: 2);
      final today = subject.getDayOfStudyFor(DateTime.now());
      await manager.saveRecall(
        recall: _recall('correction', studyDay: today - 1),
        subjectId: subject.id,
        taskId: 'task',
        interventionId: 'intervention',
        periodId: 'period',
        studyDaySnapshot: today - 1,
        progressCompletedAt: DateTime.utc(2026, 7, 15, 12),
      );

      await manager.submitPendingRecalls(subject: subject, trackProgress: true);

      expect(submitted!.entryCompletedAt, isNull);
    },
  );

  test('previous-day completion stays on the recall calendar date', () async {
    final prefs = await SharedPreferences.getInstance();
    DailyRecall? submitted;
    final manager = NutritionRecallAutoSaveManager(
      preferences: prefs,
      submitter: (_, recall) async => submitted = recall,
    );
    final subject = _subject(daysAgo: 2);
    final recallDate = DateTime(2024, 12, 31);
    final today = subject.getDayOfStudyFor(DateTime.now());
    await _save(
      manager,
      DailyRecall(
        id: 'after-midnight',
        date: recallDate,
        recallMode: RecallMode.realtimeRecord,
        entryStartedAt: recallDate.add(const Duration(hours: 20)),
        lastAutoSavedAt: DateTime(2025, 1, 1, 0, 5),
        meals: [_meal('after-midnight')],
        studyDaySnapshot: today - 1,
      ),
    );

    await manager.submitPendingRecalls(subject: subject, trackProgress: true);

    expect(
      submitted!.entryCompletedAt,
      DateTime(2024, 12, 31, 23, 59, 59, 999, 999),
    );
  });

  test('saving a period-qualified draft migrates its legacy cache', () async {
    const legacyKey = 'studyu_nutrition_autosave_subject_task_3';
    const indexKey = 'studyu_nutrition_autosave_index_subject';
    final legacyRecall = _recall('legacy', studyDay: 3);
    SharedPreferences.setMockInitialValues({
      legacyKey: jsonEncode({
        'recall': legacyRecall.toJson(),
        'metadata': {
          'subjectId': 'subject',
          'taskId': 'task',
          'interventionId': 'intervention',
          'periodId': 'period',
          'studyDaySnapshot': 3,
          'createdAt': DateTime.utc(2026).toIso8601String(),
          'lastModifiedAt': DateTime.utc(2026).toIso8601String(),
        },
      }),
      indexKey: jsonEncode(['task_3']),
    });
    final prefs = await SharedPreferences.getInstance();
    final manager = NutritionRecallAutoSaveManager(preferences: prefs);

    await _save(manager, _recall('migrated', studyDay: 3));

    expect(prefs.getString(legacyKey), isNull);
    expect(
      (await manager.loadRecall(
        subjectId: 'subject',
        taskId: 'task',
        periodId: 'period',
        studyDay: 3,
      ))!.id,
      'migrated',
    );
    expect(
      (await manager.scanPendingRecalls('subject')).single.recall.id,
      'migrated',
    );
  });

  test(
    'failed recall deletion keeps the pending recall discoverable',
    () async {
      final prefs = await SharedPreferences.getInstance();
      final savingManager = NutritionRecallAutoSaveManager(preferences: prefs);
      final manager = NutritionRecallAutoSaveManager(
        preferences: prefs,
        keyRemover: (_, _) async => false,
      );
      await _save(savingManager, _recall('retry-delete', studyDay: 1));

      await expectLater(
        manager.deleteRecall(subjectId: 'subject', taskId: 'task', studyDay: 1),
        throwsA(isA<StateError>()),
      );

      expect(
        (await manager.scanPendingRecalls('subject')).single.recall.id,
        'retry-delete',
      );
    },
  );

  test('newer recall survives previous-day submission', () async {
    final prefs = await SharedPreferences.getInstance();
    final subject = _subject(daysAgo: 2);
    final today = subject.getDayOfStudyFor(DateTime.now());
    final newerManager = NutritionRecallAutoSaveManager(preferences: prefs);
    final submitterManager = NutritionRecallAutoSaveManager(
      preferences: prefs,
      submitter: (_, _) =>
          _save(newerManager, _recall('newer', studyDay: today - 1)),
    );
    await _save(submitterManager, _recall('submitted', studyDay: today - 1));

    await submitterManager.submitPendingRecalls(
      subject: subject,
      trackProgress: true,
    );

    expect(
      (await submitterManager.scanPendingRecalls(subject.id)).single.recall.id,
      'newer',
    );
  });

  test('failed previous-day upload retains the pending recall', () async {
    final prefs = await SharedPreferences.getInstance();
    final manager = NutritionRecallAutoSaveManager(
      preferences: prefs,
      submitter: (_, _) => throw const SocketException('offline'),
    );
    final subject = _subject(daysAgo: 2);
    final today = subject.getDayOfStudyFor(DateTime.now());
    await _save(manager, _recall('retry', studyDay: today - 1));

    await manager.submitPendingRecalls(subject: subject, trackProgress: true);

    expect(await manager.scanPendingRecalls(subject.id), hasLength(1));
  });

  test('old failed recalls are never pruned by age', () async {
    final prefs = await SharedPreferences.getInstance();
    final manager = NutritionRecallAutoSaveManager(
      preferences: prefs,
      submitter: (_, _) => throw const SocketException('offline'),
    );
    final subject = _subject(daysAgo: 10);
    await _save(manager, _recall('old-retry', studyDay: 0));

    await manager.submitPendingRecalls(subject: subject, trackProgress: true);

    expect(await manager.scanPendingRecalls(subject.id), hasLength(1));
  });
}

Future<void> _save(
  NutritionRecallAutoSaveManager manager,
  DailyRecall recall,
) => manager.saveRecall(
  recall: recall,
  subjectId: 'subject',
  taskId: 'task',
  interventionId: 'intervention',
  periodId: 'period',
  studyDaySnapshot: recall.studyDaySnapshot!,
);

DailyRecall _recall(String id, {required int studyDay}) => DailyRecall(
  id: id,
  date: DateTime.now(),
  recallMode: RecallMode.realtimeRecord,
  entryStartedAt: DateTime.now(),
  meals: [_meal(id)],
  studyDaySnapshot: studyDay,
);

MealLog _meal(String id) => MealLog(
  id: id,
  mealType: MealType.breakfast,
  mealContext: MealContext.home,
  timezone: 'UTC',
  isSkipped: false,
  foods: [],
);

class _DelayedRecallLoadManager extends NutritionRecallAutoSaveManager {
  final _loadStarted = Completer<void>();
  final _pending = Completer<PendingRecall?>();

  _DelayedRecallLoadManager({required SharedPreferences preferences})
    : super(preferences: preferences);

  Future<void> get loadStarted => _loadStarted.future;

  void complete(PendingRecall pending) => _pending.complete(pending);

  @override
  Future<PendingRecall?> loadPendingRecall({
    required String subjectId,
    required String taskId,
    required String periodId,
    required int studyDay,
  }) {
    _loadStarted.complete();
    return _pending.future;
  }
}

StudySubject _subject({required int daysAgo}) {
  final subject = StudySubject('subject', 'study', 'user', [])
    ..startedAt = DateTime.now().subtract(Duration(days: daysAgo));
  final study = Study('study', 'user')
    ..schedule = (StudySchedule()..numberOfCycles = 0)
    ..interventions = [];
  subject.study = study;
  return subject;
}
