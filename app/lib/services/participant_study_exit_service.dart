import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:studyu_app/services/participant_fitbit_credentials_service.dart';
import 'package:studyu_app/services/restore_account_service.dart';
import 'package:studyu_core/core.dart';
import 'package:studyu_flutter_common/studyu_flutter_common.dart';
import 'package:supabase/supabase.dart' show PostgrestException;

enum StudyExitMode { softDelete, hardDelete }

class StudyExitResult {
  final bool success;
  final bool localFitbitCleanupFailed;
  final bool isOfflineFailure;
  final String? errorMessage;

  const StudyExitResult._({
    required this.success,
    required this.localFitbitCleanupFailed,
    required this.isOfflineFailure,
    this.errorMessage,
  });

  const StudyExitResult.success({bool localFitbitCleanupFailed = false})
    : this._(
        success: true,
        localFitbitCleanupFailed: localFitbitCleanupFailed,
        isOfflineFailure: false,
      );

  const StudyExitResult.failure({
    required bool isOfflineFailure,
    String? errorMessage,
  }) : this._(
         success: false,
         localFitbitCleanupFailed: false,
         isOfflineFailure: isOfflineFailure,
         errorMessage: errorMessage,
       );
}

class ParticipantStudyExitService {
  static Future<void> Function(String) _remoteFitbitDeletion =
      ParticipantFitbitCredentialsService.deleteRemoteFitbitCredentials;
  static Future<void> Function(String) _localFitbitCleanup =
      ParticipantFitbitCredentialsService.clearLocalFallbackCredentialsForStudy;
  static Future<void> Function() _activeStudyReferenceDeletion =
      deleteActiveStudyReference;
  static Future<void> Function() _localDataDeletion = deleteLocalData;
  static void Function() _recoveryCacheClearer =
      RestoreAccountService.clearCache;

  static Future<StudyExitResult> exitStudy({
    required StudySubject subject,
    required StudyExitMode mode,
    required Future<void> Function() notificationCleanup,
  }) async {
    try {
      await _remoteFitbitDeletion(subject.studyId);
    } on FitbitCredentialDeletionException {
      return const StudyExitResult.failure(
        isOfflineFailure: false,
        errorMessage: 'fitbit_remote_deletion_failed',
      );
    }

    try {
      switch (mode) {
        case StudyExitMode.softDelete:
          await subject.softDelete();
        case StudyExitMode.hardDelete:
          try {
            await subject.delete();
          } on PostgrestException catch (e) {
            if (e.code != 'PGRST116') rethrow;
          }
      }
    } on SocketException {
      return const StudyExitResult.failure(isOfflineFailure: true);
    } on PostgrestException catch (e) {
      return StudyExitResult.failure(
        isOfflineFailure: false,
        errorMessage: e.message,
      );
    }

    switch (mode) {
      case StudyExitMode.softDelete:
        await _activeStudyReferenceDeletion();
      case StudyExitMode.hardDelete:
        _recoveryCacheClearer();
        await _localDataDeletion();
    }

    var localFitbitCleanupFailed = false;
    try {
      await _localFitbitCleanup(subject.studyId);
    } on FitbitCredentialDeletionException catch (e) {
      localFitbitCleanupFailed = e.localDeletionFailed;
      StudyULogger.warning(
        'Participant Fitbit credentials were deleted remotely but local cleanup failed.',
      );
    }

    await notificationCleanup();
    return StudyExitResult.success(
      localFitbitCleanupFailed: localFitbitCleanupFailed,
    );
  }

  @visibleForTesting
  static Future<void> Function(String)
  get debugRemoteFitbitDeletionForTesting => _remoteFitbitDeletion;

  @visibleForTesting
  static set debugRemoteFitbitDeletionForTesting(
    Future<void> Function(String) value,
  ) {
    _remoteFitbitDeletion = value;
  }

  @visibleForTesting
  static Future<void> Function(String) get debugLocalFitbitCleanupForTesting =>
      _localFitbitCleanup;

  @visibleForTesting
  static set debugLocalFitbitCleanupForTesting(
    Future<void> Function(String) value,
  ) {
    _localFitbitCleanup = value;
  }

  @visibleForTesting
  static Future<void> Function()
  get debugActiveStudyReferenceDeletionForTesting =>
      _activeStudyReferenceDeletion;

  @visibleForTesting
  static set debugActiveStudyReferenceDeletionForTesting(
    Future<void> Function() value,
  ) {
    _activeStudyReferenceDeletion = value;
  }

  @visibleForTesting
  static Future<void> Function() get debugLocalDataDeletionForTesting =>
      _localDataDeletion;

  @visibleForTesting
  static set debugLocalDataDeletionForTesting(Future<void> Function() value) {
    _localDataDeletion = value;
  }

  @visibleForTesting
  static void Function() get debugRecoveryCacheClearerForTesting =>
      _recoveryCacheClearer;

  @visibleForTesting
  static set debugRecoveryCacheClearerForTesting(void Function() value) {
    _recoveryCacheClearer = value;
  }

  @visibleForTesting
  static void debugResetTestingOverrides() {
    _remoteFitbitDeletion =
        ParticipantFitbitCredentialsService.deleteRemoteFitbitCredentials;
    _localFitbitCleanup = ParticipantFitbitCredentialsService
        .clearLocalFallbackCredentialsForStudy;
    _activeStudyReferenceDeletion = deleteActiveStudyReference;
    _localDataDeletion = deleteLocalData;
    _recoveryCacheClearer = RestoreAccountService.clearCache;
  }
}
