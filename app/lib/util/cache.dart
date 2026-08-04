import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:studyu_app/util/temporary_storage_handler.dart';
import 'package:studyu_core/core.dart';
import 'package:studyu_flutter_common/studyu_flutter_common.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class Cache {
  static bool isSynchronizing = false;
  static const _scopedCachePrefix = '${cacheSubjectKey}_';
  static Future<bool> Function(String) _containsKey = SecureStorage.containsKey;
  static Future<String?> Function(String) _readValue = SecureStorage.read;
  static Future<void> Function(String, String) _writeValue =
      SecureStorage.write;
  static Future<void> Function(String) _deleteValue = SecureStorage.delete;
  static Future<Map<String, String>> Function() _readAllValues =
      SecureStorage.readAll;
  static String? Function() _currentUserIdGetter = _defaultCurrentUserId;
  static Future<String?> Function() _activeSubjectIdGetter = getActiveSubjectId;

  static String _scopedCacheKey(String userId, String subjectId) =>
      '$_scopedCachePrefix${userId}_$subjectId';

  static String? _defaultCurrentUserId() =>
      Supabase.instance.client.auth.currentUser?.id;

  static Future<String?> _preferredCacheKey({
    StudySubject? subject,
    StudySubject? backupSubject,
  }) async {
    final targetSubject = subject ?? backupSubject;
    if (targetSubject != null) {
      return _scopedCacheKey(targetSubject.userId, targetSubject.id);
    }

    final currentUserId = _currentUserIdGetter();
    final activeSubjectId = await _activeSubjectIdGetter();
    if (currentUserId == null || activeSubjectId == null) return null;
    return _scopedCacheKey(currentUserId, activeSubjectId);
  }

  static ({String userId, String subjectId})? _expectedCacheIdentity({
    StudySubject? subject,
    StudySubject? backupSubject,
    String? currentUserId,
    String? activeSubjectId,
  }) {
    final targetSubject = subject ?? backupSubject;
    if (targetSubject != null) {
      return (userId: targetSubject.userId, subjectId: targetSubject.id);
    }
    if (currentUserId != null && activeSubjectId != null) {
      return (userId: currentUserId, subjectId: activeSubjectId);
    }
    return null;
  }

  static ({String? userId, String? subjectId}) _extractCachedIdentity(
    Map<String, dynamic> cachedSubject,
  ) => (
    userId: cachedSubject['user_id'] as String?,
    subjectId: cachedSubject['id'] as String?,
  );

  static void _validateCachedSubjectIdentity(
    Map<String, dynamic> cachedSubject, {
    StudySubject? backupSubject,
  }) {
    final identity = _extractCachedIdentity(cachedSubject);
    final currentUserId = _currentUserIdGetter();

    if (backupSubject != null) {
      if (identity.userId != backupSubject.userId ||
          identity.subjectId != backupSubject.id) {
        throw Exception('Cached subject does not match remote subject');
      }
      return;
    }

    if (currentUserId != null &&
        identity.userId != null &&
        identity.userId != currentUserId) {
      throw Exception('Cached subject belongs to a different user');
    }
  }

  static Future<String?> _readCachedSubjectString({
    StudySubject? subject,
    StudySubject? backupSubject,
  }) async {
    final scopedKey = await _preferredCacheKey(
      subject: subject,
      backupSubject: backupSubject,
    );
    if (scopedKey != null && await _containsKey(scopedKey)) {
      return await _readValue(scopedKey);
    }

    if (!await _containsKey(cacheSubjectKey)) {
      return null;
    }

    final legacyCache = await _readValue(cacheSubjectKey);
    if (legacyCache == null) return null;

    late final Map<String, dynamic> cachedSubject;
    try {
      cachedSubject = jsonDecode(legacyCache) as Map<String, dynamic>;
    } catch (e) {
      StudyULogger.warning('Failed to parse legacy cached subject JSON: $e');
      await _deleteValue(cacheSubjectKey);
      return null;
    }

    final expectedIdentity = _expectedCacheIdentity(
      subject: subject,
      backupSubject: backupSubject,
      currentUserId: _currentUserIdGetter(),
      activeSubjectId: await _activeSubjectIdGetter(),
    );

    if (expectedIdentity == null) {
      return legacyCache;
    }

    final actualIdentity = _extractCachedIdentity(cachedSubject);
    final matchesExpected =
        actualIdentity.userId == expectedIdentity.userId &&
        actualIdentity.subjectId == expectedIdentity.subjectId;
    if (!matchesExpected) {
      await _deleteValue(cacheSubjectKey);
      return null;
    }

    final migratedKey = _scopedCacheKey(
      expectedIdentity.userId,
      expectedIdentity.subjectId,
    );
    await _writeValue(migratedKey, legacyCache);
    await _deleteValue(cacheSubjectKey);
    return legacyCache;
  }

  static Future<StudySubject> _decodeCachedSubject(
    String cachedSubjectStr, {
    StudySubject? backupSubject,
  }) async {
    final cachedSubject = jsonDecode(cachedSubjectStr) as Map<String, dynamic>;
    _validateCachedSubjectIdentity(cachedSubject, backupSubject: backupSubject);

    try {
      return StudySubject.fromJson(cachedSubject);
    } catch (e) {
      StudyULogger.warning("Failed to parse cached subject: $cachedSubjectStr");
      if (backupSubject != null) {
        final cachedProgress = (cachedSubject['progress'] as List?)
            ?.map((e) => SubjectProgress.fromJson(e as Map<String, dynamic>))
            .toList();
        backupSubject.progress = cachedProgress ?? backupSubject.progress;
        return backupSubject;
      }
      throw Exception("No backup subject provided");
    }
  }

  static Future<void> storeSubject(StudySubject? subject) async {
    // debugPrint("Store subject in cache");
    if (subject == null) return;
    final scopedKey = _scopedCacheKey(subject.userId, subject.id);
    await _writeValue(scopedKey, jsonEncode(subject.toFullJson()));
    if (await _containsKey(cacheSubjectKey)) {
      await _deleteValue(cacheSubjectKey);
    }
    assert(subject == (await loadSubject(backupSubject: subject)));
  }

  static Future<StudySubject> loadSubject({StudySubject? backupSubject}) async {
    // debugPrint("Load subject from cache");
    final cachedSubjectStr = await _readCachedSubjectString(
      backupSubject: backupSubject,
    );
    if (cachedSubjectStr == null) {
      throw Exception("No cached subject found");
    }

    return _decodeCachedSubject(cachedSubjectStr, backupSubject: backupSubject);
  }

  static Future<void> storeAnalytics(StudyUAnalytics analytics) async {
    SecureStorage.write(
      StudyUAnalytics.keyStudyUAnalytics,
      jsonEncode(analytics.toJson()),
    );
  }

  static Future<StudyUAnalytics?> loadAnalytics() async {
    try {
      if (await _containsKey(StudyUAnalytics.keyStudyUAnalytics)) {
        final analyticsData = await _readValue(
          StudyUAnalytics.keyStudyUAnalytics,
        );
        if (analyticsData != null) {
          return StudyUAnalytics.fromJson(
            jsonDecode(analyticsData) as Map<String, dynamic>,
          );
        }
      }
    } catch (e) {
      StudyULogger.warning("Failed to load analytics from cache: $e");
    }
    return null;
  }

  static Future<void> delete() async {
    StudyULogger.warning("Delete cache");
    await clearAllSubjectCaches();
  }

  static Future<void> clearAllSubjectCaches() async {
    final storedValues = await _readAllValues();
    for (final key in storedValues.keys) {
      if (key == cacheSubjectKey || key.startsWith(_scopedCachePrefix)) {
        await _deleteValue(key);
      }
    }
  }

  static Future<void> clearRecoverySubjectCaches({
    required String? recoveredUserId,
    required String? recoveredSubjectId,
  }) async {
    final storedValues = await _readAllValues();
    final preservedKey = recoveredUserId != null && recoveredSubjectId != null
        ? _scopedCacheKey(recoveredUserId, recoveredSubjectId)
        : null;

    for (final key in storedValues.keys) {
      final isSubjectCacheKey =
          key == cacheSubjectKey || key.startsWith(_scopedCachePrefix);
      if (!isSubjectCacheKey) continue;
      if (preservedKey != null && key == preservedKey) continue;
      await _deleteValue(key);
    }
  }

  static Future<void> uploadBlobFiles() async {
    final blobStorageHandler = BlobStorageHandler();
    final futureBlobFiles = await TemporaryStorageHandler.getFutureBlobFiles();
    for (final futureBlobFile in futureBlobFiles) {
      await blobStorageHandler.uploadObservation(
        futureBlobFile.futureBlobId,
        File(futureBlobFile.localFilePath),
      );
      await File(futureBlobFile.localFilePath).delete();
    }
  }

  static Future<StudySubject> synchronize(StudySubject remoteSubject) async {
    if (isSynchronizing) return remoteSubject;
    // No local subject found
    final cachedSubjectStr = await _readCachedSubjectString(
      backupSubject: remoteSubject,
    );
    if (cachedSubjectStr == null) {
      return remoteSubject;
    }
    final localSubject = await _decodeCachedSubject(
      cachedSubjectStr,
      backupSubject: remoteSubject,
    );
    // local and remote subject are equal, nothing to synchronize
    if (localSubject == remoteSubject) return remoteSubject;
    // remote subject belongs to a different study
    if (!kDebugMode &&
        remoteSubject.startedAt!.isAfter(localSubject.startedAt!)) {
      return remoteSubject;
    }

    debugPrint("Synchronize subject with cache");
    isSynchronizing = true;

    try {
      await uploadBlobFiles();

      // only minimal update
      // Check if progress has changed
      if (localSubject.progress.length != remoteSubject.progress.length) {
        StudyULogger.info("Cache synchronization: Merging progress");
        /*if (remoteSubject.progress.isNotEmpty) {
        // sort remote progress list from oldest to newest
        remoteSubject.progress.sort((a, b) =>
            a.completedAt.compareTo(b.completedAt));
        // merge all local progress older than the latest remote progress to remote subject and upload
        newProgress = localSubject.progress.where((element) =>
            element.completedAt.isAfter(remoteSubject.progress.last.completedAt)
        ).toList();
      } else {
        newProgress = localSubject.progress;
      }*/
        // save new progress
        final List<SubjectProgress> newProgress = [
          ...localSubject.progress,
          ...remoteSubject.progress,
        ];
        newProgress.removeWhere(
          (element) =>
              localSubject.progress.contains(element) &&
              remoteSubject.progress.contains(element),
        );
        for (final p in newProgress) {
          await p.save();
        }

        // merge local and remote progress and remove duplicates
        final List<SubjectProgress> finalProgress = [
          ...localSubject.progress,
          ...remoteSubject.progress,
        ];
        final duplicates = <DateTime?>{};
        finalProgress.retainWhere(
          (element) => duplicates.add(element.completedAt),
        );
        // replace remote progress with our merge
        remoteSubject.progress = finalProgress;
        await remoteSubject.save(onlyUpdate: true);
      } else {
        // Unable to determine what has changed
        // We can either drop local or overwrite remote
        // ... for now do nothing
        if (!kDebugMode && localSubject.startedAt == remoteSubject.startedAt) {
          StudyULogger.fatal(
            "Cache synchronization found local changes that cannot be merged",
          );
          StudyULogger.error(
            "localSubject: ${localSubject.toFullJson()} \nremoteSubject: ${remoteSubject.toFullJson()}",
          );
        }
      }
    } catch (exception) {
      StudyULogger.warning(exception);
    }
    isSynchronizing = false;
    return remoteSubject;
  }

  static Future<String> getCachedUserData() async {
    final debugInfo = StringBuffer();
    debugInfo.writeln('=== Cached User Data Debug Info ===');

    try {
      // Check selected subject ID
      if (await _containsKey('selected_study_object_id')) {
        final selectedSubjectId = await _readValue('selected_study_object_id');
        debugInfo.writeln('Selected Subject ID: $selectedSubjectId');
      } else {
        debugInfo.writeln('Selected Subject ID: NOT FOUND');
      }

      // Check user email
      if (await SecureStorage.containsKey('user_email')) {
        final userEmail = await SecureStorage.read('user_email');
        debugInfo.writeln('User Email: $userEmail');
      } else {
        debugInfo.writeln('User Email: NOT FOUND');
      }

      // Check cached subject
      final storedValues = await SecureStorage.readAll();
      final cacheKeys = storedValues.keys
          .where(
            (key) =>
                key == cacheSubjectKey || key.startsWith(_scopedCachePrefix),
          )
          .toList();
      if (cacheKeys.isNotEmpty) {
        debugInfo.writeln('Cache Subject: EXISTS (data present)');
        try {
          final cachedSubject = await loadSubject();
          debugInfo.writeln('  - Subject ID: ${cachedSubject.id}');
          debugInfo.writeln('  - Study ID: ${cachedSubject.studyId}');
          debugInfo.writeln('  - Started At: ${cachedSubject.startedAt}');
          debugInfo.writeln(
            '  - Progress Count: ${cachedSubject.progress.length}',
          );
        } catch (e) {
          debugInfo.writeln('  - Error loading cached subject: $e');
        }
      } else {
        debugInfo.writeln('Cache Subject: NOT FOUND');
      }

      // Check user password (without revealing the actual password)
      if (await SecureStorage.containsKey('user_password')) {
        debugInfo.writeln('User Password: EXISTS (hidden for security)');
      } else {
        debugInfo.writeln('User Password: NOT FOUND');
      }
    } catch (e) {
      debugInfo.writeln('Error retrieving cached data: $e');
    }

    return debugInfo.toString();
  }

  @visibleForTesting
  static Future<bool> Function(String) get debugContainsKeyForTesting =>
      _containsKey;

  @visibleForTesting
  static set debugContainsKeyForTesting(Future<bool> Function(String) value) {
    _containsKey = value;
  }

  @visibleForTesting
  static Future<String?> Function(String) get debugReadValueForTesting =>
      _readValue;

  @visibleForTesting
  static set debugReadValueForTesting(Future<String?> Function(String) value) {
    _readValue = value;
  }

  @visibleForTesting
  static Future<void> Function(String, String) get debugWriteValueForTesting =>
      _writeValue;

  @visibleForTesting
  static set debugWriteValueForTesting(
    Future<void> Function(String, String) value,
  ) {
    _writeValue = value;
  }

  @visibleForTesting
  static Future<void> Function(String) get debugDeleteValueForTesting =>
      _deleteValue;

  @visibleForTesting
  static set debugDeleteValueForTesting(Future<void> Function(String) value) {
    _deleteValue = value;
  }

  @visibleForTesting
  static Future<Map<String, String>> Function()
  get debugReadAllValuesForTesting => _readAllValues;

  @visibleForTesting
  static set debugReadAllValuesForTesting(
    Future<Map<String, String>> Function() value,
  ) {
    _readAllValues = value;
  }

  @visibleForTesting
  static String? Function() get debugCurrentUserIdGetterForTesting =>
      _currentUserIdGetter;

  @visibleForTesting
  static set debugCurrentUserIdGetterForTesting(String? Function() value) {
    _currentUserIdGetter = value;
  }

  @visibleForTesting
  static Future<String?> Function() get debugActiveSubjectIdGetterForTesting =>
      _activeSubjectIdGetter;

  @visibleForTesting
  static set debugActiveSubjectIdGetterForTesting(
    Future<String?> Function() value,
  ) {
    _activeSubjectIdGetter = value;
  }

  @visibleForTesting
  static void debugResetTestingOverrides() {
    _containsKey = SecureStorage.containsKey;
    _readValue = SecureStorage.read;
    _writeValue = SecureStorage.write;
    _deleteValue = SecureStorage.delete;
    _readAllValues = SecureStorage.readAll;
    _currentUserIdGetter = _defaultCurrentUserId;
    _activeSubjectIdGetter = getActiveSubjectId;
  }
}
