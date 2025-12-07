import 'dart:async';

import 'package:flutter/material.dart';
import 'package:studyu_app/util/nutrition_recall_autosave_manager.dart';
import 'package:studyu_app/util/study_subject_extension.dart';
import 'package:studyu_core/core.dart';

class DailyRecallEntryViewModel extends ChangeNotifier {
  final StudySubject? subject;
  final NutritionTask? task;
  final CompletionPeriod? completionPeriod;
  final NutritionRecallAutoSaveManager _autoSaveManager =
      NutritionRecallAutoSaveManager();

  late DailyRecall recall;
  bool isSaving = false;
  DateTime? lastSaveTime;

  Timer? _autoSaveTimer;
  int? _studyDaySnapshot;
  String? _interventionId;
  String? _periodId;
  bool _isDisposed = false;

  DailyRecallEntryViewModel({
    this.subject,
    this.task,
    this.completionPeriod,
    DailyRecall? existingRecall,
  }) {
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

      if (existing != null && !_isDisposed) {
        recall = existing;
        lastSaveTime = existing.lastAutoSavedAt;
        notifyListeners();
      } else if (!_isDisposed) {
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
    if (recall.meals.isNotEmpty && subject != null) {
      _performAutoSaveSync();
    }
    super.dispose();
  }

  void onAppLifecycleStateChanged(AppLifecycleState state) {
    if (state == AppLifecycleState.paused) {
      _autoSaveTimer?.cancel();
      if (recall.meals.isNotEmpty && subject != null) {
        _performAutoSaveSync();
      }
    }
  }

  void updateDate(DateTime newDate) {
    if (newDate != recall.date) {
      recall = _copyWithRecall(date: newDate);
      notifyListeners();
      _scheduleAutoSave('date changed');
    }
  }

  void updateRecallMode(RecallMode mode) {
    if (mode != recall.recallMode) {
      recall = _copyWithRecall(recallMode: mode);
      notifyListeners();
      _scheduleAutoSave('recall mode changed');
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
      );
      notifyListeners();
      _scheduleAutoSave('usual day toggled');
    }
  }

  void updateSpecialOccasion(String? occasion) {
    if (occasion != recall.specialOccasion) {
      recall = _copyWithRecall(specialOccasion: occasion);
      // Note: TextField controller text isn't reset here to prevent cursor jumps
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

  void removeMeal(int index) {
    recall.meals.removeAt(index);
    notifyListeners();
    _scheduleAutoSave('meal removed');
  }

  // Helper to copy recall with new fields
  DailyRecall _copyWithRecall({
    DateTime? date,
    bool? isUsualIntakeDay,
    String? specialOccasion,
    RecallMode? recallMode,
    DateTime? entryCompletedAt,
    DateTime? lastAutoSavedAt,
  }) {
    return DailyRecall(
      id: recall.id,
      date: date ?? recall.date,
      isUsualIntakeDay: isUsualIntakeDay ?? recall.isUsualIntakeDay,
      specialOccasion: specialOccasion ?? recall.specialOccasion,
      recallMode: recallMode ?? recall.recallMode,
      entryStartedAt: recall.entryStartedAt,
      entryCompletedAt: entryCompletedAt ?? recall.entryCompletedAt,
      meals: recall.meals,
      studyDaySnapshot: _studyDaySnapshot ?? recall.studyDaySnapshot,
      lastAutoSavedAt: lastAutoSavedAt ?? recall.lastAutoSavedAt,
    );
  }

  void _scheduleAutoSave([String reason = 'unspecified']) {
    if (subject == null || _studyDaySnapshot == null) return;

    StudyULogger.debug(
      '[DailyRecallVM] Schedule auto-save ($reason) | meals=${recall.meals.length} '
      'studyDay=$_studyDaySnapshot subject=${subject?.id}',
    );

    _autoSaveTimer?.cancel();
    _autoSaveTimer = Timer(NutritionRecallAutoSaveManager.debounceDuration, () {
      _performAutoSave();
    });
  }

  void _performAutoSaveSync() {
    if (subject == null || _studyDaySnapshot == null) return;

    StudyULogger.debug(
      '[DailyRecallVM] Sync auto-save (dispose/pause) | meals=${recall.meals.length} '
      'studyDay=$_studyDaySnapshot subject=${subject?.id}',
    );

    _autoSaveManager.saveRecall(
      recall: _copyWithRecall(lastAutoSavedAt: DateTime.now()),
      subjectId: subject!.id,
      taskId: task?.id ?? NutritionRecallAutoSaveManager.standaloneTaskId,
      interventionId:
          _interventionId ??
          NutritionRecallAutoSaveManager.unknownInterventionId,
      periodId: _periodId ?? NutritionRecallAutoSaveManager.defaultPeriodId,
      studyDaySnapshot: _studyDaySnapshot!,
    );
  }

  Future<void> _performAutoSave() async {
    if (isSaving || subject == null || _studyDaySnapshot == null) return;
    if (!isInTaskMode) {
      StudyULogger.debug('[DailyRecallVM] Skip auto-save (not in task mode)');
      return;
    }

    isSaving = true;
    notifyListeners();

    try {
      final now = DateTime.now();

      recall = _copyWithRecall(lastAutoSavedAt: now);

      StudyULogger.debug(
        '[DailyRecallVM] Auto-save firing | meals=${recall.meals.length} '
        'studyDay=$_studyDaySnapshot '
        'recallMode=${recall.recallMode} lastAutoSavedAt=${recall.lastAutoSavedAt}',
      );

      await _autoSaveManager.saveRecall(
        recall: recall,
        subjectId: subject!.id,
        taskId: task?.id ?? NutritionRecallAutoSaveManager.standaloneTaskId,
        interventionId:
            _interventionId ??
            NutritionRecallAutoSaveManager.unknownInterventionId,
        periodId: _periodId ?? NutritionRecallAutoSaveManager.defaultPeriodId,
        studyDaySnapshot: _studyDaySnapshot!,
      );

      if (_shouldSaveToDb) {
        await subject!.upsertNutritionResult(
          taskId: task!.id,
          periodId: completionPeriod!.id,
          recall: recall,
        );
      }

      lastSaveTime = now;
    } finally {
      isSaving = false;
      notifyListeners();
    }
  }

  bool _shouldSaveToDb = true;
  set shouldSaveToDb(bool value) => _shouldSaveToDb = value;
}
