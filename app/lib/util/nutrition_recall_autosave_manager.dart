import 'dart:convert';
import 'dart:io';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:studyu_app/util/study_subject_extension.dart';
import 'package:studyu_core/core.dart';

typedef NutritionRecallSubmitter =
    Future<void> Function(PendingRecall pending, DailyRecall recall);
typedef NutritionRecallStringWriter =
    Future<bool> Function(
      SharedPreferences preferences,
      String key,
      String value,
    );
typedef NutritionRecallKeyRemover =
    Future<bool> Function(SharedPreferences preferences, String key);

class NutritionRecallAutoSaveManager {
  static const String _keyPrefix = 'studyu_nutrition_autosave';
  static const Duration debounceDuration = Duration(seconds: 2);

  static const String standaloneTaskId = 'standalone';
  static const String unknownInterventionId = 'unknown';
  static const String defaultPeriodId = 'default';

  NutritionRecallAutoSaveManager({
    SharedPreferences? preferences,
    NutritionRecallSubmitter? submitter,
    NutritionRecallStringWriter? stringWriter,
    NutritionRecallKeyRemover? keyRemover,
  }) : _preferences = preferences,
       _submitter = submitter,
       _stringWriter = stringWriter ?? _defaultStringWriter,
       _keyRemover = keyRemover ?? _defaultKeyRemover;

  final SharedPreferences? _preferences;
  final NutritionRecallSubmitter? _submitter;
  final NutritionRecallStringWriter _stringWriter;
  final NutritionRecallKeyRemover _keyRemover;
  static final Map<String, Future<void>> _mutationQueues = {};
  SharedPreferences? _prefs;
  bool _isSubmitting = false;

  static Future<bool> _defaultStringWriter(
    SharedPreferences preferences,
    String key,
    String value,
  ) => preferences.setString(key, value);

  static Future<bool> _defaultKeyRemover(
    SharedPreferences preferences,
    String key,
  ) => preferences.remove(key);

  Future<SharedPreferences> _getPrefs() async {
    return _prefs ??= _preferences ?? await SharedPreferences.getInstance();
  }

  Future<void> saveRecall({
    required DailyRecall recall,
    required String subjectId,
    required String taskId,
    required String interventionId,
    required String periodId,
    required int studyDaySnapshot,
  }) {
    final storageKey = _buildStorageKey(subjectId, taskId, studyDaySnapshot);
    final now = DateTime.now().toIso8601String();
    final dataJson = jsonEncode({
      'recall': recall.toJson(),
      'metadata': {
        'subjectId': subjectId,
        'taskId': taskId,
        'interventionId': interventionId,
        'periodId': periodId,
        'studyDaySnapshot': studyDaySnapshot,
        'createdAt': now,
        'lastModifiedAt': now,
      },
    });

    return _mutateForSubject(subjectId, () async {
      final prefs = await _getPrefs();
      await _writeString(prefs, storageKey, dataJson);
      await _updateIndex(prefs, subjectId, taskId, studyDaySnapshot);

      StudyULogger.debug(
        '[AutoSave] Saved recall | subject=$subjectId task=$taskId studyDay=$studyDaySnapshot '
        'meals=${recall.meals.length} recallMode=${recall.recallMode} lastSaved=${recall.lastAutoSavedAt}',
      );
    });
  }

  Future<T> _mutateForSubject<T>(
    String subjectId,
    Future<T> Function() mutation,
  ) {
    final key = '${_keyPrefix}_$subjectId';
    final previous = _mutationQueues[key] ?? Future<void>.value();
    final operation = previous.then<T>(
      (_) => mutation(),
      onError: (_, _) => mutation(),
    );
    final queueTail = operation.then<void>((_) {}, onError: (_, _) {});
    _mutationQueues[key] = queueTail;
    queueTail.whenComplete(() {
      if (identical(_mutationQueues[key], queueTail)) {
        _mutationQueues.remove(key);
      }
    });
    return operation;
  }

  Future<void> _writeString(
    SharedPreferences preferences,
    String key,
    String value,
  ) async {
    if (!await _stringWriter(preferences, key, value)) {
      throw StateError('Failed to save nutrition recall cache.');
    }
  }

  Future<void> _removeKey(SharedPreferences preferences, String key) async {
    if (!await _keyRemover(preferences, key)) {
      throw StateError('Failed to remove nutrition recall cache.');
    }
  }

  Future<DailyRecall?> loadRecall({
    required String subjectId,
    required String taskId,
    required int studyDay,
  }) async {
    final prefs = await _getPrefs();
    final storageKey = _buildStorageKey(subjectId, taskId, studyDay);

    final dataJson = prefs.getString(storageKey);
    if (dataJson == null) return null;

    try {
      final data = jsonDecode(dataJson) as Map<String, dynamic>;
      return DailyRecall.fromJson(data['recall'] as Map<String, dynamic>);
    } catch (e) {
      StudyULogger.error('Failed to load auto-saved recall: $e');
      return null;
    }
  }

  Future<List<PendingRecall>> scanPendingRecalls(String subjectId) async {
    final prefs = await _getPrefs();
    final indexKey = '${_keyPrefix}_index_$subjectId';
    final indexJson = prefs.getString(indexKey);

    if (indexJson == null) return [];

    final index = List<String>.from(jsonDecode(indexJson) as List);
    final pending = <PendingRecall>[];

    for (final entry in index) {
      final parts = entry.split('_');
      if (parts.length != 2) continue;

      final taskId = parts[0];
      final studyDay = int.tryParse(parts[1]);
      if (studyDay == null) continue;

      final storageKey = _buildStorageKey(subjectId, taskId, studyDay);
      final dataJson = prefs.getString(storageKey);

      if (dataJson != null) {
        try {
          final data = jsonDecode(dataJson) as Map<String, dynamic>;
          final metadata = data['metadata'] as Map<String, dynamic>;

          pending.add(
            PendingRecall(
              recall: DailyRecall.fromJson(
                data['recall'] as Map<String, dynamic>,
              ),
              subjectId: metadata['subjectId'] as String,
              taskId: metadata['taskId'] as String,
              interventionId: metadata['interventionId'] as String,
              periodId: metadata['periodId'] as String,
              studyDaySnapshot: metadata['studyDaySnapshot'] as int,
              lastModifiedAt: metadata['lastModifiedAt'] as String,
            ),
          );
        } catch (e) {
          StudyULogger.error('Failed to parse pending recall: $e');
        }
      }
    }

    StudyULogger.debug(
      '[AutoSave] scanPendingRecalls | subject=$subjectId found=${pending.length}',
    );

    return pending;
  }

  Future<void> deleteRecall({
    required String subjectId,
    required String taskId,
    required int studyDay,
  }) => _mutateForSubject(subjectId, () async {
    final prefs = await _getPrefs();
    final storageKey = _buildStorageKey(subjectId, taskId, studyDay);

    await _removeKey(prefs, storageKey);
    await _removeFromIndex(prefs, subjectId, taskId, studyDay);

    StudyULogger.info(
      'Deleted auto-save for task $taskId, study day $studyDay',
    );
  });

  Future<void> _deleteRecallIfUnchanged(PendingRecall pending) {
    return _mutateForSubject(pending.subjectId, () async {
      final prefs = await _getPrefs();
      final storageKey = _buildStorageKey(
        pending.subjectId,
        pending.taskId,
        pending.studyDaySnapshot,
      );
      final dataJson = prefs.getString(storageKey);
      if (dataJson == null) return;

      try {
        final data = jsonDecode(dataJson) as Map<String, dynamic>;
        final metadata = data['metadata'] as Map<String, dynamic>;
        if (metadata['lastModifiedAt'] != pending.lastModifiedAt) return;
      } catch (error) {
        StudyULogger.error('Failed to compare pending recall revision: $error');
        return;
      }

      await _removeKey(prefs, storageKey);
      await _removeFromIndex(
        prefs,
        pending.subjectId,
        pending.taskId,
        pending.studyDaySnapshot,
      );
    });
  }

  Future<void> submitPendingRecalls({
    required StudySubject subject,
    required bool trackProgress,
  }) async {
    if (_isSubmitting || !trackProgress) return;
    _isSubmitting = true;

    try {
      final todayStudyDay = subject.getDayOfStudyFor(DateTime.now());
      StudyULogger.debug(
        '[AutoSave] submitPendingRecalls start | subject=${subject.id} todayStudyDay=$todayStudyDay trackProgress=$trackProgress',
      );

      final pendingRecalls = await scanPendingRecalls(subject.id);

      for (final pending in pendingRecalls) {
        if (pending.studyDaySnapshot > todayStudyDay) {
          StudyULogger.debug(
            '[AutoSave] skip pending submit (future day) | studyDay=${pending.studyDaySnapshot} today=$todayStudyDay',
          );
          continue;
        }
        if (pending.studyDaySnapshot < 0) {
          StudyULogger.warning(
            '[AutoSave] skip pending submit (invalid negative day) | studyDay=${pending.studyDaySnapshot}',
          );
          continue;
        }

        final isPreviousDay = pending.studyDaySnapshot < todayStudyDay;
        final recall = isPreviousDay
            ? _finalizeRecall(pending.recall, pending.studyDaySnapshot)
            : pending.recall;

        try {
          if (_submitter != null) {
            await _submitter(pending, recall);
          } else {
            await subject.upsertNutritionResult(
              taskId: pending.taskId,
              periodId: pending.periodId,
              recall: recall,
              completionDateOverride: isPreviousDay
                  ? recall.entryCompletedAt
                  : null,
            );
          }

          if (isPreviousDay) {
            await _deleteRecallIfUnchanged(pending);
          }
        } on SocketException catch (_) {
          StudyULogger.warning(
            'Network error while submitting pending recall for study day '
            '${pending.studyDaySnapshot}. Will retry later.',
          );
        } catch (e) {
          StudyULogger.error(
            'Failed to submit pending recall for study day '
            '${pending.studyDaySnapshot}: $e',
          );
        }
      }

      await updateLastKnownStudyDay(subject.id, todayStudyDay);
    } finally {
      _isSubmitting = false;
    }
  }

  DailyRecall _finalizeRecall(DailyRecall recall, int studyDaySnapshot) {
    final now = DateTime.now();
    final dayStart = DateTime(
      recall.date.year,
      recall.date.month,
      recall.date.day,
    );
    final dayEnd = DateTime(
      recall.date.year,
      recall.date.month,
      recall.date.day + 1,
    ).subtract(const Duration(microseconds: 1));
    final completionCandidate =
        recall.entryCompletedAt ??
        recall.lastAutoSavedAt ??
        recall.entryStartedAt ??
        now;
    final completedAt = completionCandidate.isBefore(dayStart)
        ? dayStart
        : completionCandidate.isAfter(dayEnd)
        ? dayEnd
        : completionCandidate;

    return DailyRecall(
      id: recall.id,
      date: recall.date,
      isUsualIntakeDay: recall.isUsualIntakeDay,
      specialOccasion: recall.specialOccasion,
      recallMode: recall.recallMode,
      entryStartedAt: recall.entryStartedAt,
      entryCompletedAt: completedAt,
      meals: recall.meals,
      studyDaySnapshot: recall.studyDaySnapshot ?? studyDaySnapshot,
      lastAutoSavedAt: recall.lastAutoSavedAt ?? recall.entryCompletedAt ?? now,
    );
  }

  Future<int?> getLastKnownStudyDay(String subjectId) async {
    final prefs = await _getPrefs();
    final key = '${_keyPrefix}_last_study_day_$subjectId';
    final value = prefs.getString(key);
    return value != null ? int.tryParse(value) : null;
  }

  Future<void> updateLastKnownStudyDay(String subjectId, int studyDay) async {
    final prefs = await _getPrefs();
    final key = '${_keyPrefix}_last_study_day_$subjectId';
    await _writeString(prefs, key, studyDay.toString());
  }

  String _buildStorageKey(String subjectId, String taskId, int studyDay) {
    return '${_keyPrefix}_${subjectId}_${taskId}_$studyDay';
  }

  Future<void> _updateIndex(
    SharedPreferences prefs,
    String subjectId,
    String taskId,
    int studyDay,
  ) async {
    final indexKey = '${_keyPrefix}_index_$subjectId';
    final indexJson = prefs.getString(indexKey);

    final index = indexJson != null
        ? List<String>.from(jsonDecode(indexJson) as List)
        : <String>[];

    final entry = '${taskId}_$studyDay';
    if (!index.contains(entry)) {
      index.add(entry);
      await _writeString(prefs, indexKey, jsonEncode(index));
    }
  }

  Future<void> _removeFromIndex(
    SharedPreferences prefs,
    String subjectId,
    String taskId,
    int studyDay,
  ) async {
    final indexKey = '${_keyPrefix}_index_$subjectId';
    final indexJson = prefs.getString(indexKey);

    if (indexJson == null) return;

    final index = List<String>.from(jsonDecode(indexJson) as List);
    final entry = '${taskId}_$studyDay';

    if (index.remove(entry)) {
      if (index.isEmpty) {
        await _removeKey(prefs, indexKey);
      } else {
        await _writeString(prefs, indexKey, jsonEncode(index));
      }
    }
  }
}

class PendingRecall {
  final DailyRecall recall;
  final String subjectId;
  final String taskId;
  final String interventionId;
  final String periodId;
  final int studyDaySnapshot;
  final String lastModifiedAt;

  PendingRecall({
    required this.recall,
    required this.subjectId,
    required this.taskId,
    required this.interventionId,
    required this.periodId,
    required this.studyDaySnapshot,
    required this.lastModifiedAt,
  });
}
