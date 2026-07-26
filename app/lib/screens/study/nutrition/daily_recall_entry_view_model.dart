import 'dart:async';

import 'package:flutter/material.dart';
import 'package:studyu_app/util/nutrition_recall_autosave_manager.dart';
import 'package:studyu_app/util/study_subject_extension.dart';
import 'package:studyu_core/core.dart';

class DailyRecallEntryViewModel extends ChangeNotifier {
  final StudySubject? subject;
  final NutritionTask? task;
  final CompletionPeriod? completionPeriod;
  final NutritionRecallAutoSaveManager _autoSaveManager;

  late DailyRecall recall;
  bool isSaving = false;
  DateTime? lastSaveTime;

  Timer? _autoSaveTimer;
  Future<void>? _autoSaveFuture;
  Future<void> _localSaveFuture = Future.value();
  Future<void> _remoteSaveQueue = Future.value();
  int? _studyDaySnapshot;
  String? _interventionId;
  String? _periodId;
  bool _isDisposed = false;

  DailyRecallEntryViewModel({
    this.subject,
    this.task,
    this.completionPeriod,
    DailyRecall? existingRecall,
    NutritionRecallAutoSaveManager? autoSaveManager,
  }) : _autoSaveManager = autoSaveManager ?? NutritionRecallAutoSaveManager() {
    if (existingRecall != null) {
      recall = existingRecall;
      _studyDaySnapshot = recall.studyDaySnapshot;
      lastSaveTime = recall.lastAutoSavedAt;
    } else {
      recall = DailyRecall.withId(
        date: DateTime.now(),
        recallMode: RecallMode.realtimeRecord,
        entryStartedAt: DateTime.now(),
        meals: [],
      );
    }
    _initialize();
  }

  bool get isInTaskMode => task != null && completionPeriod != null;

  bool get meetsMinimumMeals {
    final minimum = task?.minimumMealsRequired;
    if (minimum == null) return true;
    final nonSkippedCount = recall.meals.where((m) => !m.isSkipped).length;
    return nonSkippedCount >= minimum;
  }

  Future<void> _initialize() async {
    if (subject == null) return;

    _studyDaySnapshot ??= subject!.getDayOfStudyFor(DateTime.now());
    _interventionId ??= subject!.getInterventionForDate(DateTime.now())?.id;

    if (task != null && completionPeriod != null) {
      _periodId = completionPeriod!.id;
    }

    if (_studyDaySnapshot == null) return;

    if (recall.meals.isEmpty &&
        recall.specialOccasion == null &&
        recall.isUsualIntakeDay == null) {
      final existing = await _autoSaveManager.loadRecall(
        subjectId: subject!.id,
        taskId: task?.id ?? NutritionRecallAutoSaveManager.standaloneTaskId,
        studyDay: _studyDaySnapshot!,
      );

      final canRestore =
          recall.meals.isEmpty &&
          recall.specialOccasion == null &&
          recall.isUsualIntakeDay == null;
      if (existing != null && !_isDisposed && canRestore) {
        recall = existing;
        lastSaveTime = existing.lastAutoSavedAt;
        notifyListeners();
      } else if (!_isDisposed && canRestore) {
        recall = DailyRecall(
          id: recall.id,
          date: recall.date,
          recallMode: recall.recallMode,
          entryStartedAt: recall.entryStartedAt,
          meals: recall.meals,
          studyDaySnapshot: _studyDaySnapshot,
        );
      }
    }
  }

  @override
  void dispose() {
    _isDisposed = true;
    _autoSaveTimer?.cancel();
    if (_hasRecallContent && subject != null) {
      _performAutoSaveSync();
    }
    super.dispose();
  }

  void onAppLifecycleStateChanged(AppLifecycleState state) {
    if (state == AppLifecycleState.paused) {
      _autoSaveTimer?.cancel();
      if (_hasRecallContent && subject != null) {
        _performAutoSaveSync();
      }
    }
  }

  void updateUsualIntake(bool isUsual) {
    if (isUsual != recall.isUsualIntakeDay) {
      String? specialOccasion = recall.specialOccasion;
      if (isUsual) {
        specialOccasion = null;
      }
      recall = _copyWithRecall(
        isUsualIntakeDay: isUsual,
        specialOccasion: specialOccasion,
        clearSpecialOccasion: specialOccasion == null,
      );
      notifyListeners();
      _scheduleAutoSave('usual day toggled');
    }
  }

  void updateSpecialOccasion(String? occasion) {
    if (occasion != recall.specialOccasion) {
      recall = _copyWithRecall(
        specialOccasion: occasion,
        clearSpecialOccasion: occasion == null,
      );
      // Note: TextField controller text isn't reset here to prevent cursor jumps
      notifyListeners();
      _scheduleAutoSave('special occasion changed');
    }
  }

  void addMeal(MealLog meal) {
    recall.meals.add(meal);
    notifyListeners();
    _scheduleAutoSave('meal added');
  }

  void updateMeal(int index, MealLog meal) {
    recall.meals[index] = meal;
    notifyListeners();
    _scheduleAutoSave('meal edited');
  }

  void updateMealById(String mealId, MealLog meal) {
    final index = recall.meals.indexWhere((entry) => entry.id == mealId);
    if (index == -1) return;
    updateMeal(index, meal);
  }

  void removeMeal(int index) {
    recall.meals.removeAt(index);
    notifyListeners();
    _scheduleAutoSave('meal removed');
  }

  void removeMealById(String mealId) {
    final index = recall.meals.indexWhere((entry) => entry.id == mealId);
    if (index == -1) return;
    removeMeal(index);
  }

  // Helper to copy recall with new fields
  DailyRecall _copyWithRecall({
    bool? isUsualIntakeDay,
    String? specialOccasion,
    bool clearSpecialOccasion = false,
    DateTime? entryCompletedAt,
    bool clearEntryCompletedAt = false,
    DateTime? lastAutoSavedAt,
  }) {
    return DailyRecall(
      id: recall.id,
      date: recall.date,
      isUsualIntakeDay: isUsualIntakeDay ?? recall.isUsualIntakeDay,
      specialOccasion: clearSpecialOccasion
          ? null
          : specialOccasion ?? recall.specialOccasion,
      recallMode: recall.recallMode,
      entryStartedAt: recall.entryStartedAt,
      entryCompletedAt: clearEntryCompletedAt
          ? null
          : entryCompletedAt ?? recall.entryCompletedAt,
      meals: recall.meals,
      studyDaySnapshot: _studyDaySnapshot ?? recall.studyDaySnapshot,
      lastAutoSavedAt: lastAutoSavedAt ?? recall.lastAutoSavedAt,
    );
  }

  DailyRecall markCompleted() {
    final completedAt = DateTime.now();
    recall = _copyWithRecall(entryCompletedAt: completedAt);
    notifyListeners();
    return recall;
  }

  /// Cancels a scheduled remote upsert and waits for the latest local cache.
  Future<void> flushPendingAutoSave({bool persistToDatabase = false}) async {
    final hadScheduledSave = _autoSaveTimer != null;
    _autoSaveTimer?.cancel();
    _autoSaveTimer = null;

    await _localSaveFuture;

    if (persistToDatabase && hadScheduledSave) {
      await _performAutoSave();
    } else {
      final pendingSave = _autoSaveFuture;
      if (pendingSave != null) await pendingSave;
    }
  }

  void _scheduleAutoSave([String reason = 'unspecified']) {
    if (subject == null || _studyDaySnapshot == null) return;

    StudyULogger.debug(
      '[DailyRecallVM] Schedule auto-save ($reason) | meals=${recall.meals.length} '
      'studyDay=$_studyDaySnapshot subject=${subject?.id}',
    );

    _persistLocalSnapshot();
    _autoSaveTimer?.cancel();
    _autoSaveTimer = Timer(NutritionRecallAutoSaveManager.debounceDuration, () {
      _autoSaveTimer = null;
      _autoSaveFuture = _performAutoSave();
    });
  }

  bool get _hasRecallContent =>
      recall.meals.isNotEmpty ||
      recall.specialOccasion != null ||
      recall.isUsualIntakeDay != null;

  void _performAutoSaveSync() {
    if (subject == null || _studyDaySnapshot == null) return;
    _persistLocalSnapshot();
  }

  void _persistLocalSnapshot() {
    if (subject == null || _studyDaySnapshot == null) return;

    recall = _copyWithRecall(lastAutoSavedAt: DateTime.now());
    final localSave = _autoSaveManager.saveRecall(
      recall: recall,
      subjectId: subject!.id,
      taskId: task?.id ?? NutritionRecallAutoSaveManager.standaloneTaskId,
      interventionId:
          _interventionId ??
          NutritionRecallAutoSaveManager.unknownInterventionId,
      periodId: _periodId ?? NutritionRecallAutoSaveManager.defaultPeriodId,
      studyDaySnapshot: _studyDaySnapshot!,
    );
    _localSaveFuture = localSave;
    localSave.catchError((Object error, StackTrace stackTrace) {
      StudyULogger.error(
        '[DailyRecallVM] Local auto-save failed: $error\n$stackTrace',
      );
    });
  }

  Future<void> _performAutoSave() {
    if (subject == null || _studyDaySnapshot == null || !isInTaskMode) {
      return Future.value();
    }

    final recallToSave = DailyRecall.fromJson(recall.toJson());
    final now = recallToSave.lastAutoSavedAt ?? DateTime.now();
    final remoteSave = _remoteSaveQueue.then((_) async {
      isSaving = true;
      notifyListeners();
      try {
        if (shouldSaveToDb) {
          await subject!.upsertNutritionResult(
            taskId: task!.id,
            periodId: completionPeriod!.id,
            recall: recallToSave,
          );
        }
        lastSaveTime = now;
      } catch (error, stackTrace) {
        StudyULogger.warning(
          '[DailyRecallVM] Remote auto-save failed; local recall is retained: '
          '$error\n$stackTrace',
        );
      } finally {
        isSaving = false;
        notifyListeners();
      }
    });
    _remoteSaveQueue = remoteSave;
    return remoteSave;
  }

  bool shouldSaveToDb = true;
}
