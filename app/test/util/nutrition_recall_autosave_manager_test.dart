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

StudySubject _subject({required int daysAgo}) {
  final subject = StudySubject('subject', 'study', 'user', [])
    ..startedAt = DateTime.now().subtract(Duration(days: daysAgo));
  final study = Study('study', 'user')
    ..schedule = (StudySchedule()..numberOfCycles = 0)
    ..interventions = [];
  subject.study = study;
  return subject;
}
