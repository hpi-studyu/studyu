import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:studyu_app/util/cache.dart';
import 'package:studyu_app/util/fitbit_handler.dart';
import 'package:studyu_core/core.dart';
import 'package:studyu_flutter_common/studyu_flutter_common.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

Future<StudySubject?> resolveCachedSubjectForCleanup({
  StudySubject? fallbackSubject,
}) async {
  try {
    return await Cache.loadSubject(backupSubject: fallbackSubject);
  } catch (_) {
    return fallbackSubject;
  }
}

Future<void> _clearStudyLocalData({
  StudySubject? fallbackSubject,
  bool clearStoredParticipantCredentials = false,
}) async {
  final subject = await resolveCachedSubjectForCleanup(
    fallbackSubject: fallbackSubject,
  );
  await Cache.deletePendingBlobFilesForSubject(subject);
  if (subject != null) {
    await FitbitHandler.deleteFitbitCredentials(subject.studyId);
  }
  await deleteActiveStudyReference();
  await Cache.delete();
  if (clearStoredParticipantCredentials) {
    await clearParticipantCredentials();
  }
}

Future<void> clearStudyLocalData({
  StudySubject? fallbackSubject,
  bool clearStoredParticipantCredentials = false,
}) {
  return Cache.runWithSubjectSynchronizationBlocked(
    () => _clearStudyLocalData(
      fallbackSubject: fallbackSubject,
      clearStoredParticipantCredentials: clearStoredParticipantCredentials,
    ),
  );
}

Future<bool> deleteStudySubjectAndClearLocalData({
  required StudySubject subject,
  required Future<bool> Function() synchronizeActiveSubject,
  required Future<void> Function() deleteRemoteSubject,
  required FutureOr<void> Function() onRemoteDeleted,
  required Future<void> Function() stopActiveSynchronization,
  required FutureOr<void> Function() resumeActiveSynchronization,
  bool clearStoredParticipantCredentials = false,
}) async {
  await stopActiveSynchronization();
  var remoteDeleted = false;
  try {
    final deleted = await Cache.runWithSubjectSynchronizationBlocked(() async {
      if (!await synchronizeActiveSubject()) return false;
      await deleteRemoteSubject();
      remoteDeleted = true;
      await onRemoteDeleted();
      await _clearStudyLocalData(
        fallbackSubject: subject,
        clearStoredParticipantCredentials: clearStoredParticipantCredentials,
      );
      return true;
    });
    if (!deleted) await resumeActiveSynchronization();
    return deleted;
  } catch (_) {
    if (!remoteDeleted) await resumeActiveSynchronization();
    rethrow;
  }
}

Future<void> _clearParticipantSessionForReset({
  Future<void> Function()? clearSession,
  void Function()? stopAutoRefresh,
}) async {
  try {
    (stopAutoRefresh ?? Supabase.instance.client.auth.stopAutoRefresh)();
  } catch (error) {
    StudyULogger.warning(
      'Could not stop participant auth refresh during reset: $error',
    );
  }
  try {
    await (clearSession ?? clearParticipantSession)();
  } catch (error) {
    StudyULogger.warning(
      'Could not clear participant session during reset: $error',
    );
  }
}

Future<void> clearAllLocalData({
  @visibleForTesting Future<void> Function()? clearSession,
  @visibleForTesting void Function()? stopAutoRefresh,
}) {
  return Cache.runWithSubjectSynchronizationBlocked(() async {
    await _clearParticipantSessionForReset(
      clearSession: clearSession,
      stopAutoRefresh: stopAutoRefresh,
    );
    await Cache.delete();
    await SecureStorage.deleteAll();
  });
}
