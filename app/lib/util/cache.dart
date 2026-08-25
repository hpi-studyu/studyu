import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:studyu_app/util/temporary_storage_handler.dart';
import 'package:studyu_core/core.dart';
import 'package:studyu_flutter_common/studyu_flutter_common.dart';

typedef CacheSynchronizationResult = ({
  StudySubject subject,
  bool succeeded,
  Object? error,
});

typedef _CachedSubjectSnapshot = ({StudySubject? subject, int revision});

class Cache {
  static bool isSynchronizing = false;
  static int _subjectRevision = 0;
  static Future<void>? _subjectWriteInFlight;

  @visibleForTesting
  static Future<void> Function(String studyId, String userId)?
  debugUploadBlobFilesOverride;

  @visibleForTesting
  static Future<SubjectProgress> Function(SubjectProgress progress)?
  debugSaveProgressOverride;

  @visibleForTesting
  static Future<StudySubject> Function(StudySubject subject)?
  debugSaveSubjectOverride;

  @visibleForTesting
  static Future<void> Function()? debugAfterSubjectSnapshotLoaded;

  @visibleForTesting
  static void debugResetSubjectWrites() {
    _subjectRevision = 0;
    _subjectWriteInFlight = null;
    debugAfterSubjectSnapshotLoaded = null;
  }

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
      saveProgress: debugSaveProgressOverride ?? (progress) => progress.save(),
      saveSubject:
          debugSaveSubjectOverride ??
          (subject) => subject.save(onlyUpdate: true),
    );
  }

  static Future<T> _queueSubjectWrite<T>(Future<T> Function() write) async {
    while (_subjectWriteInFlight != null) {
      await _subjectWriteInFlight;
    }
    final completed = Completer<void>();
    _subjectWriteInFlight = completed.future;
    try {
      return await write();
    } finally {
      _subjectWriteInFlight = null;
      completed.complete();
    }
  }

  static Future<void> _writeSubject(StudySubject subject) {
    return SecureStorage.write(
      cacheSubjectKey,
      jsonEncode(subject.toFullJson()),
    );
  }

  static Future<void> storeSubject(StudySubject? subject) async {
    // debugPrint("Store subject in cache");
    if (subject == null) return;
    _subjectRevision++;
    await _queueSubjectWrite(() => _writeSubject(subject));
  }

  static Future<bool> _storeSubjectIfRevisionUnchanged(
    StudySubject subject,
    int expectedRevision,
  ) {
    if (_subjectRevision != expectedRevision) return Future.value(false);
    final reservedRevision = ++_subjectRevision;
    return _queueSubjectWrite(() async {
      if (_subjectRevision != reservedRevision) return false;
      await _writeSubject(subject);
      return _subjectRevision == reservedRevision;
    });
  }

  static Future<_CachedSubjectSnapshot> _loadSubjectSnapshot({
    StudySubject? backupSubject,
  }) async {
    while (true) {
      while (_subjectWriteInFlight != null) {
        await _subjectWriteInFlight;
      }
      final revision = _subjectRevision;
      final subject = await SecureStorage.containsKey(cacheSubjectKey)
          ? await loadSubject(backupSubject: backupSubject)
          : null;
      if (revision == _subjectRevision) {
        return (subject: subject, revision: revision);
      }
    }
  }

  static Future<CacheSynchronizationResult>
  _successfulSynchronizationIfRevisionUnchanged({
    required StudySubject subject,
    required StudySubject backupSubject,
    required int expectedRevision,
  }) async {
    if (_subjectRevision == expectedRevision) {
      return (subject: subject, succeeded: true, error: null);
    }
    final latest = await _loadSubjectSnapshot(backupSubject: backupSubject);
    return (subject: latest.subject ?? subject, succeeded: false, error: null);
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

  static Future<CacheSynchronizationResult> synchronize(
    StudySubject remoteSubject,
  ) async {
    final snapshot = await _loadSubjectSnapshot(backupSubject: remoteSubject);
    await debugAfterSubjectSnapshotLoaded?.call();
    final localSubject = snapshot.subject;
    if (localSubject == null) {
      return _successfulSynchronizationIfRevisionUnchanged(
        subject: remoteSubject,
        backupSubject: remoteSubject,
        expectedRevision: snapshot.revision,
      );
    }
    if (isSynchronizing) {
      return (subject: localSubject, succeeded: false, error: null);
    }
    if (!isCompatibleCachedSubject(
      localSubject: localSubject,
      remoteSubject: remoteSubject,
    )) {
      StudyULogger.warning(
        'Skip cache synchronization because cached subject does not match remote subject',
      );
      return _successfulSynchronizationIfRevisionUnchanged(
        subject: remoteSubject,
        backupSubject: remoteSubject,
        expectedRevision: snapshot.revision,
      );
    }
    // local and remote subject are equal, nothing to synchronize
    if (localSubject == remoteSubject) {
      return _successfulSynchronizationIfRevisionUnchanged(
        subject: remoteSubject,
        backupSubject: remoteSubject,
        expectedRevision: snapshot.revision,
      );
    }
    // remote subject belongs to a different study
    if (!kDebugMode &&
        remoteSubject.startedAt!.isAfter(localSubject.startedAt!)) {
      return _successfulSynchronizationIfRevisionUnchanged(
        subject: remoteSubject,
        backupSubject: remoteSubject,
        expectedRevision: snapshot.revision,
      );
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
      final stored = await _storeSubjectIfRevisionUnchanged(
        remoteSubject,
        snapshot.revision,
      );
      if (!stored) {
        final latestSubject = await _loadSubjectSnapshot(
          backupSubject: remoteSubject,
        );
        return (
          subject: latestSubject.subject ?? localSubject,
          succeeded: false,
          error: null,
        );
      }
      appConnectionStatusController.setStatus(AppConnectionStatus.healthy);
      return (subject: remoteSubject, succeeded: true, error: null);
    } catch (exception) {
      final status = connectionStatusFromError(exception);
      if (status != null) {
        appConnectionStatusController.setStatus(status);
      }
      StudyULogger.warning(exception);
      return (subject: localSubject, succeeded: false, error: exception);
    } finally {
      isSynchronizing = false;
    }
  }

  static bool containsAllProgress({
    required StudySubject subject,
    required StudySubject progressSource,
  }) {
    final subjectProgress = subject.progress.map(_progressSyncKey).toSet();
    return progressSource.progress.every(
      (progress) => subjectProgress.contains(_progressSyncKey(progress)),
    );
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
