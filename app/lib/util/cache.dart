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

  static String _scopedCacheKey(String userId, String subjectId) =>
      '$_scopedCachePrefix${userId}_$subjectId';

  static Future<String?> _preferredCacheKey({
    StudySubject? subject,
    StudySubject? backupSubject,
  }) async {
    final targetSubject = subject ?? backupSubject;
    if (targetSubject != null) {
      return _scopedCacheKey(targetSubject.userId, targetSubject.id);
    }

    final currentUserId = Supabase.instance.client.auth.currentUser?.id;
    final activeSubjectId = await getActiveSubjectId();
    if (currentUserId == null || activeSubjectId == null) return null;
    return _scopedCacheKey(currentUserId, activeSubjectId);
  }

  static Future<String?> _readCachedSubjectString({
    StudySubject? subject,
    StudySubject? backupSubject,
  }) async {
    final scopedKey = await _preferredCacheKey(
      subject: subject,
      backupSubject: backupSubject,
    );
    if (scopedKey != null && await SecureStorage.containsKey(scopedKey)) {
      return await SecureStorage.read(scopedKey);
    }
    if (await SecureStorage.containsKey(cacheSubjectKey)) {
      return await SecureStorage.read(cacheSubjectKey);
    }
    return null;
  }

  static Future<StudySubject> _decodeCachedSubject(
    String cachedSubjectStr, {
    StudySubject? backupSubject,
  }) async {
    final cachedSubject = jsonDecode(cachedSubjectStr) as Map<String, dynamic>;
    final cachedUserId = cachedSubject['user_id'] as String?;
    final currentUserId = Supabase.instance.client.auth.currentUser?.id;

    if (currentUserId != null &&
        cachedUserId != null &&
        cachedUserId != currentUserId) {
      throw Exception('Cached subject belongs to a different user');
    }

    try {
      return StudySubject.fromJson(cachedSubject);
    } catch (e) {
      StudyULogger.warning("Failed to parse cached subject: $cachedSubjectStr");
      if (backupSubject != null) {
        if (backupSubject.id != cachedSubject['id']) {
          throw Exception("Cached subject ID does not match remote subject ID");
        }
        if (backupSubject.userId != cachedSubject['user_id']) {
          throw Exception(
            "Cached subject user does not match remote subject user",
          );
        }
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
    await SecureStorage.write(scopedKey, jsonEncode(subject.toFullJson()));
    if (await SecureStorage.containsKey(cacheSubjectKey)) {
      await SecureStorage.delete(cacheSubjectKey);
    }
    assert(subject == (await loadSubject()));
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
      if (await SecureStorage.containsKey(StudyUAnalytics.keyStudyUAnalytics)) {
        final analyticsData = await SecureStorage.read(
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
    final storedValues = await SecureStorage.readAll();
    for (final key in storedValues.keys) {
      if (key == cacheSubjectKey || key.startsWith(_scopedCachePrefix)) {
        await SecureStorage.delete(key);
      }
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
      if (await SecureStorage.containsKey('selected_study_object_id')) {
        final selectedSubjectId = await SecureStorage.read(
          'selected_study_object_id',
        );
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
}
