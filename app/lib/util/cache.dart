import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:studyu_app/util/temporary_storage_handler.dart';
import 'package:studyu_core/core.dart';
import 'package:studyu_flutter_common/studyu_flutter_common.dart';

class Cache {
  static bool isSynchronizing = false;

  @visibleForTesting
  static Future<void> Function(String studyId, String userId)?
  debugUploadBlobFilesOverride;

  static bool isCompatibleCachedSubject({
    required StudySubject localSubject,
    required StudySubject remoteSubject,
  }) {
    return localSubject.id == remoteSubject.id &&
        localSubject.studyId == remoteSubject.studyId &&
        localSubject.userId == remoteSubject.userId;
  }

  static SubjectProgressSyncPlan buildProgressSyncPlan({
    required StudySubject localSubject,
    required StudySubject remoteSubject,
  }) {
    final remoteKeys = remoteSubject.progress
        .map((progress) => _progressSyncKey(progress))
        .toSet();
    final mergedProgress = [...remoteSubject.progress];
    final newProgress = <SubjectProgress>[];

    for (final progress in localSubject.progress) {
      final key = _progressSyncKey(progress);
      if (remoteKeys.add(key)) {
        newProgress.add(progress);
        mergedProgress.add(progress);
      }
    }

    return SubjectProgressSyncPlan(
      newProgress: newProgress,
      mergedProgress: mergedProgress,
      saveProgress: (progress) => progress.save(),
      saveSubject: (subject) => subject.save(onlyUpdate: true),
    );
  }

  static Future<void> storeSubject(StudySubject? subject) async {
    // debugPrint("Store subject in cache");
    if (subject == null) return;
    await SecureStorage.write(
      cacheSubjectKey,
      jsonEncode(subject.toFullJson()),
    );
  }

  static Future<StudySubject> loadSubject({StudySubject? backupSubject}) async {
    // debugPrint("Load subject from cache");
    if (await SecureStorage.containsKey(cacheSubjectKey)) {
      final cachedSubjectStr = await SecureStorage.read(cacheSubjectKey);
      final cachedSubject =
          jsonDecode(cachedSubjectStr!) as Map<String, dynamic>;
      try {
        return StudySubject.fromJson(cachedSubject);
      } catch (e) {
        StudyULogger.warning(
          "Failed to parse cached subject: $cachedSubjectStr",
        );
        if (backupSubject != null) {
          // Only take progress from cached subject and rest from backup,
          // as the cached subject might be outdated or corrupted

          // compare IDs to make sure we are not mixing up subjects
          // If IDs do not match we should not use the cached subject
          if (backupSubject.id != cachedSubject['id']) {
            throw Exception(
              "Cached subject ID does not match remote subject ID",
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
    } else {
      throw Exception("No cached subject found");
    }
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
    SecureStorage.delete(cacheSubjectKey);
  }

  static Future<void> uploadBlobFiles(String studyId, String userId) async {
    final blobStorageHandler = BlobStorageHandler();
    final futureBlobFiles = await TemporaryStorageHandler.getFutureBlobFiles(
      studyId: studyId,
      userId: userId,
    );
    await uploadPendingBlobFiles(
      futureBlobFiles: futureBlobFiles,
      uploadObservation: (futureBlobFile) async {
        await blobStorageHandler.uploadObservation(
          futureBlobFile.futureBlobId,
          File(futureBlobFile.localFilePath),
        );
      },
      deleteUploadedFile: (futureBlobFile) async {
        await File(futureBlobFile.localFilePath).delete();
      },
    );
  }

  static Future<void> deletePendingBlobFilesForSubject(
    StudySubject? subject,
  ) async {
    if (subject == null) return;
    try {
      await TemporaryStorageHandler.deleteFutureBlobFiles(
        studyId: subject.studyId,
        userId: subject.userId,
      );
    } catch (error) {
      StudyULogger.warning(
        'Could not delete pending blob files for subject ${subject.id}: $error',
      );
    }
  }

  static Future<StudySubject> synchronize(StudySubject remoteSubject) async {
    if (isSynchronizing) return remoteSubject;
    // No local subject found
    if (!(await SecureStorage.containsKey(cacheSubjectKey))) {
      return remoteSubject;
    }
    final localSubject = await loadSubject(backupSubject: remoteSubject);
    if (!isCompatibleCachedSubject(
      localSubject: localSubject,
      remoteSubject: remoteSubject,
    )) {
      StudyULogger.warning(
        'Skip cache synchronization because cached subject does not match remote subject',
      );
      return remoteSubject;
    }
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
      await (debugUploadBlobFilesOverride ?? uploadBlobFiles)(
        remoteSubject.studyId,
        remoteSubject.userId,
      );
      final syncPlan = buildProgressSyncPlan(
        localSubject: localSubject,
        remoteSubject: remoteSubject,
      );
      if (syncPlan.hasChanges) {
        StudyULogger.info("Cache synchronization: Merging progress");
        await applyProgressSyncPlan(
          remoteSubject: remoteSubject,
          syncPlan: syncPlan,
        );
      }
      appConnectionStatusController.setStatus(AppConnectionStatus.healthy);
    } catch (exception) {
      final status = connectionStatusFromError(exception);
      if (status != null) {
        appConnectionStatusController.setStatus(status);
      }
      StudyULogger.warning(exception);
    }
    isSynchronizing = false;
    return remoteSubject;
  }

  static String _progressSyncKey(SubjectProgress progress) =>
      jsonEncode(progress.toJson());

  static Future<void> uploadPendingBlobFiles({
    required List<FutureBlobFile> futureBlobFiles,
    required Future<void> Function(FutureBlobFile futureBlobFile)
    uploadObservation,
    required Future<void> Function(FutureBlobFile futureBlobFile)
    deleteUploadedFile,
  }) async {
    for (final futureBlobFile in futureBlobFiles) {
      await uploadObservation(futureBlobFile);
      await deleteUploadedFile(futureBlobFile);
    }
  }

  static Future<void> applyProgressSyncPlan({
    required StudySubject remoteSubject,
    required SubjectProgressSyncPlan syncPlan,
  }) async {
    for (final progress in syncPlan.newProgress) {
      await syncPlan.saveProgress(progress);
    }
    remoteSubject.progress = syncPlan.mergedProgress;
    await syncPlan.saveSubject(remoteSubject);
  }

  static Future<String> getCachedUserData() async {
    final debugInfo = StringBuffer();
    debugInfo.writeln('=== Cached User Data Debug Info ===');

    try {
      // Check selected subject ID
      if (await SecureStorage.containsKey(selectedSubjectIdKey)) {
        final selectedSubjectId = await SecureStorage.read(
          selectedSubjectIdKey,
        );
        debugInfo.writeln('Selected Subject ID: $selectedSubjectId');
      } else {
        debugInfo.writeln('Selected Subject ID: NOT FOUND');
      }

      // Check user email
      if (await SecureStorage.containsKey(userEmailKey)) {
        final userEmail = await SecureStorage.read(userEmailKey);
        debugInfo.writeln('User Email: $userEmail');
      } else {
        debugInfo.writeln('User Email: NOT FOUND');
      }

      // Check cached subject
      if (await SecureStorage.containsKey('cache_subject')) {
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
      if (await SecureStorage.containsKey(userPasswordKey)) {
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

class SubjectProgressSyncPlan {
  final List<SubjectProgress> newProgress;
  final List<SubjectProgress> mergedProgress;
  final Future<SubjectProgress> Function(SubjectProgress progress) saveProgress;
  final Future<StudySubject> Function(StudySubject subject) saveSubject;

  const SubjectProgressSyncPlan({
    required this.newProgress,
    required this.mergedProgress,
    required this.saveProgress,
    required this.saveSubject,
  });

  bool get hasChanges => newProgress.isNotEmpty;
}
