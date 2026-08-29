import 'dart:async';

import 'package:flutter/material.dart';
import 'package:studyu_app/util/cache.dart';
import 'package:studyu_app/util/notifications.dart';
import 'package:studyu_app/util/schedule_notifications.dart';
import 'package:studyu_core/core.dart';
import 'package:studyu_flutter_common/studyu_flutter_common.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

const _activeSubjectSyncRetryDelay = Duration(seconds: 5);
const _activeSubjectSyncSelectedColumns = [
  '*',
  'study!study_subject_studyId_fkey(*, study_fitbit_credentials:study_fitbit_credentials_studyId_fkey(*))',
  'subject_progress(*)',
];

class AppState with ChangeNotifier {
  Study? selectedStudy;
  List<Intervention>? selectedInterventions;
  StudySubject? activeSubject;
  String? inviteCode;
  List<String>? preselectedInterventionIds;
  StudyNotifications? studyNotifications;
  bool isPreview = false;

  String? pendingDeepLinkStudyId;
  String? pendingDeepLinkInviteCode;
  late final VoidCallback _connectionStatusListener;
  AppConnectionStatus _connectionStatus = appConnectionStatusController.status;
  Timer? _activeSubjectSyncRetryTimer;
  Future<void>? _activeSubjectSyncFuture;
  bool _activeSubjectSyncStopped = false;
  bool _activeSubjectSyncPending = false;
  StreamSubscription<StudySubject>? _activeSubjectCacheSubscription;
  StudySubject? _activeSubjectCacheSource;

  @visibleForTesting
  Future<StudySubject?> Function(String subjectId)?
  debugFetchRemoteSubjectForSync;

  @visibleForTesting
  Duration? debugActiveSubjectSyncRetryDelay;

  @visibleForTesting
  Future<bool> Function()? debugRestoreParticipantSessionForSync;

  @visibleForTesting
  bool Function()? debugHasParticipantSessionForSync;

  bool get hasPendingDeepLink =>
      pendingDeepLinkStudyId != null || pendingDeepLinkInviteCode != null;

  AppConnectionStatus get connectionStatus => _connectionStatus;

  void clearPendingDeepLink() {
    pendingDeepLinkStudyId = null;
    pendingDeepLinkInviteCode = null;
    notifyListeners();
  }

  /// Flag indicating whether the participant's progress should be tracked
  ///
  /// We always track the participant's progress except when the study is
  /// being viewed in test/preview mode while already launched (to avoid
  /// mixing results from test users with actual participants)
  bool get trackParticipantProgress => !(isPreview && selectedStudy!.isRunning);

  AppState() {
    _connectionStatusListener = () {
      _applyConnectionStatus(appConnectionStatusController.status);
    };
    appConnectionStatusController.addListener(_connectionStatusListener);
  }

  void init(BuildContext context) {
    scheduleNotifications(context);
    _syncActiveSubjectCache();
    scheduleActiveSubjectSyncRetryIfNeeded();
  }

  void _syncActiveSubjectCache() {
    final currentSubject = activeSubject;
    if (currentSubject == null) return;
    if (identical(_activeSubjectCacheSource, currentSubject) &&
        _activeSubjectCacheSubscription != null) {
      return;
    }

    _activeSubjectCacheSubscription?.cancel();
    _activeSubjectCacheSource = currentSubject;

    _activeSubjectCacheSubscription = currentSubject.onSave.listen((
      StudySubject subject,
    ) async {
      if (_activeSubjectSyncStopped ||
          !identical(_activeSubjectCacheSource, currentSubject)) {
        return;
      }
      activeSubject = subject;
      if (selectedStudy == null || selectedStudy?.id == subject.study.id) {
        selectedStudy = subject.study;
      }
      _syncActiveSubjectCache();
      await Cache.storeSubject(subject);
      scheduleActiveSubjectSyncRetryIfNeeded();
      notifyListeners();
    });
  }

  void updateActiveSubject(
    StudySubject? subject, {
    bool notifyListenersNow = true,
    bool updateSelectedStudy = true,
  }) {
    final hadActiveSubject = activeSubject != null;
    activeSubject = subject;
    if (!hadActiveSubject && subject != null) {
      _activeSubjectSyncStopped = false;
    }
    if (updateSelectedStudy) {
      selectedStudy = subject?.study;
    }
    _syncActiveSubjectCache();
    scheduleActiveSubjectSyncRetryIfNeeded();
    if (notifyListenersNow) {
      notifyListeners();
    }
  }

  void updateStudy(Study study) {
    // todo baseline
    study.schedule.includeBaseline = false;
    selectedStudy = study;
    if (activeSubject?.study.id == study.id) {
      activeSubject!.study = study;
    }
    notifyListeners();
  }

  /// Updates the preview mode state for the debug mode of the app
  ///
  /// Sets [isPreview] to the given value and updates [selectedStudy]
  /// to the active subject's study. Notifies listeners of the change.
  void updatePreviewMode(bool preview) {
    isPreview = preview;
    selectedStudy = activeSubject?.study;
    notifyListeners();
  }

  void setConnectionStatus(AppConnectionStatus status) {
    appConnectionStatusController.setStatus(status);
  }

  void clearActiveStudyState() {
    _activeSubjectSyncStopped = true;
    _activeSubjectSyncPending = false;
    _cancelActiveSubjectSyncRetry();
    _activeSubjectCacheSubscription?.cancel();
    _activeSubjectCacheSubscription = null;
    _activeSubjectCacheSource = null;
    selectedStudy = null;
    selectedInterventions = null;
    activeSubject = null;
    inviteCode = null;
    preselectedInterventionIds = null;
    studyNotifications = null;
    notifyListeners();
  }

  void _applyConnectionStatus(AppConnectionStatus status) {
    if (_connectionStatus == status) return;
    _connectionStatus = status;
    scheduleActiveSubjectSyncRetryIfNeeded();
    notifyListeners();
  }

  void markActiveSubjectSynchronizationPending() {
    if (_activeSubjectSyncStopped) return;
    _activeSubjectSyncPending = true;
    scheduleActiveSubjectSyncRetryIfNeeded();
  }

  void scheduleActiveSubjectSyncRetryIfNeeded() {
    if (_activeSubjectSyncStopped ||
        activeSubject == null ||
        (_connectionStatus == AppConnectionStatus.healthy &&
            !_activeSubjectSyncPending)) {
      _cancelActiveSubjectSyncRetry();
      return;
    }
    _activeSubjectSyncRetryTimer ??= Timer.periodic(
      debugActiveSubjectSyncRetryDelay ?? _activeSubjectSyncRetryDelay,
      (_) => unawaited(retryCachedSubjectSynchronization()),
    );
  }

  void _cancelActiveSubjectSyncRetry() {
    _activeSubjectSyncRetryTimer?.cancel();
    _activeSubjectSyncRetryTimer = null;
  }

  Future<void> retryCachedSubjectSynchronization() {
    if (_activeSubjectSyncStopped) return Future.value();
    final activeSynchronization = _activeSubjectSyncFuture;
    if (activeSynchronization != null) return activeSynchronization;

    late final Future<void> synchronization;
    synchronization = _retryCachedSubjectSynchronization().whenComplete(() {
      if (identical(_activeSubjectSyncFuture, synchronization)) {
        _activeSubjectSyncFuture = null;
      }
    });
    _activeSubjectSyncFuture = synchronization;
    return synchronization;
  }

  Future<void> _retryCachedSubjectSynchronization() async {
    final currentSubject = activeSubject;
    if (currentSubject == null) {
      _cancelActiveSubjectSyncRetry();
      return;
    }
    await _attemptCachedSubjectSynchronization(currentSubject);
  }

  Future<bool> synchronizeActiveSubjectBeforeDestructiveAction() async {
    final currentSubject = activeSubject;
    if (currentSubject == null) return false;
    return _attemptCachedSubjectSynchronization(
      currentSubject,
      allowWhileBlocked: true,
    );
  }

  Future<bool> _attemptCachedSubjectSynchronization(
    StudySubject currentSubject, {
    bool allowWhileBlocked = false,
  }) async {
    try {
      final hasParticipantSession =
          (debugHasParticipantSessionForSync ?? isUserLoggedIn)();
      if (!hasParticipantSession) {
        final bool didRestoreSession;
        try {
          didRestoreSession =
              await (debugRestoreParticipantSessionForSync ??
                  _restoreParticipantSessionForSync)();
        } on AuthApiException catch (error) {
          if (error.code == 'invalid_credentials') return false;
          rethrow;
        }
        if (!didRestoreSession || activeSubject?.id != currentSubject.id) {
          return false;
        }
      }
      return await _synchronizeCachedSubject(
        currentSubject,
        allowWhileBlocked: allowWhileBlocked,
      );
    } catch (error) {
      final status = connectionStatusFromError(error);
      if (status != null) {
        appConnectionStatusController.setStatus(status);
        return false;
      }
      if (!shouldAttemptParticipantAuthRecovery(error)) {
        return false;
      }
      final bool didRestoreSession;
      try {
        didRestoreSession =
            await (debugRestoreParticipantSessionForSync ??
                _restoreParticipantSessionForSync)();
      } on AuthApiException catch (error) {
        if (error.code == 'invalid_credentials') return false;
        rethrow;
      }
      if (!didRestoreSession || activeSubject?.id != currentSubject.id) {
        return false;
      }
      try {
        return await _synchronizeCachedSubject(
          currentSubject,
          allowWhileBlocked: allowWhileBlocked,
        );
      } catch (recoveryError) {
        final recoveryStatus = connectionStatusFromError(recoveryError);
        if (recoveryStatus != null) {
          appConnectionStatusController.setStatus(recoveryStatus);
        }
        return false;
      }
    }
  }

  Future<void> stopAndAwaitActiveSubjectSynchronization() async {
    _activeSubjectSyncStopped = true;
    _activeSubjectSyncPending = false;
    _cancelActiveSubjectSyncRetry();
    try {
      await _activeSubjectSyncFuture;
    } catch (error) {
      StudyULogger.warning(
        'Active subject synchronization stopped with an error: $error',
      );
    } finally {
      _activeSubjectSyncPending = false;
    }
  }

  Future<void> resumeActiveSubjectSynchronization() async {
    final currentSubject = activeSubject;
    if (currentSubject == null) return;
    _activeSubjectSyncStopped = false;
    _activeSubjectSyncPending = true;
    try {
      await Cache.storeSubject(currentSubject);
    } catch (error) {
      StudyULogger.warning(
        'Could not restore active subject cache after failed deletion: $error',
      );
    } finally {
      scheduleActiveSubjectSyncRetryIfNeeded();
    }
  }

  Future<bool> _synchronizeCachedSubject(
    StudySubject currentSubject, {
    bool allowWhileBlocked = false,
  }) async {
    final fetchRemoteSubject =
        debugFetchRemoteSubjectForSync ?? _fetchRemoteSubjectForSync;
    final remoteSubject = await fetchRemoteSubject(currentSubject.id);
    if (remoteSubject == null || activeSubject?.id != currentSubject.id) {
      return false;
    }
    final synchronization = await Cache.synchronize(
      remoteSubject,
      allowWhileBlocked: allowWhileBlocked,
    );
    final latestActiveSubject = activeSubject;
    if (!synchronization.succeeded ||
        latestActiveSubject?.id != currentSubject.id) {
      markActiveSubjectSynchronizationPending();
      if (synchronization.error != null) throw synchronization.error!;
      return false;
    }
    if (!Cache.containsAllProgress(
          subject: synchronization.subject,
          progressSource: latestActiveSubject!,
        ) ||
        await Cache.hasDeferredFitbitRequestsForSubject(currentSubject.id)) {
      markActiveSubjectSynchronizationPending();
      return false;
    }
    _activeSubjectSyncPending = false;
    appConnectionStatusController.setStatus(AppConnectionStatus.healthy);
    updateActiveSubject(synchronization.subject);
    _cancelActiveSubjectSyncRetry();
    return true;
  }

  Future<bool> _restoreParticipantSessionForSync() async {
    await clearParticipantSession();
    return signInParticipant();
  }

  Future<StudySubject?> _fetchRemoteSubjectForSync(String subjectId) {
    return SupabaseQuery.getById<StudySubject>(
      subjectId,
      selectedColumns: _activeSubjectSyncSelectedColumns,
    );
  }

  @override
  void dispose() {
    _activeSubjectSyncStopped = true;
    _cancelActiveSubjectSyncRetry();
    _activeSubjectCacheSubscription?.cancel();
    _activeSubjectCacheSource = null;
    appConnectionStatusController.removeListener(_connectionStatusListener);
    super.dispose();
  }
}
