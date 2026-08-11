import 'dart:async';

import 'package:flutter/material.dart';
import 'package:studyu_app/util/cache.dart';
import 'package:studyu_app/util/notifications.dart';
import 'package:studyu_app/util/schedule_notifications.dart';
import 'package:studyu_core/core.dart';
import 'package:studyu_flutter_common/studyu_flutter_common.dart';

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
  bool _activeSubjectSyncInFlight = false;
  StreamSubscription<StudySubject>? _activeSubjectCacheSubscription;
  StudySubject? _activeSubjectCacheSource;

  @visibleForTesting
  Future<StudySubject?> Function(String subjectId)?
  debugFetchRemoteSubjectForSync;

  @visibleForTesting
  Duration? debugActiveSubjectSyncRetryDelay;

  @visibleForTesting
  Future<bool> Function()? debugRestoreParticipantSessionForSync;

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
      activeSubject = subject;
      if (selectedStudy == null || selectedStudy?.id == subject.study.id) {
        selectedStudy = subject.study;
      }
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
    activeSubject = subject;
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
    if (status == AppConnectionStatus.healthy) {
      _cancelActiveSubjectSyncRetry();
    } else {
      scheduleActiveSubjectSyncRetryIfNeeded();
    }
    notifyListeners();
  }

  void scheduleActiveSubjectSyncRetryIfNeeded() {
    if (_connectionStatus == AppConnectionStatus.healthy ||
        activeSubject == null) {
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

  Future<void> retryCachedSubjectSynchronization() async {
    if (_activeSubjectSyncInFlight) return;
    final currentSubject = activeSubject;
    if (currentSubject == null) {
      _cancelActiveSubjectSyncRetry();
      return;
    }
    _activeSubjectSyncInFlight = true;
    try {
      await _synchronizeCachedSubject(currentSubject);
    } catch (error) {
      final status = connectionStatusFromError(error);
      if (status != null) {
        appConnectionStatusController.setStatus(status);
        return;
      }
      if (!shouldAttemptParticipantAuthRecovery(error)) {
        return;
      }
      final didRestoreSession =
          await (debugRestoreParticipantSessionForSync ??
              _restoreParticipantSessionForSync)();
      if (!didRestoreSession || activeSubject?.id != currentSubject.id) {
        return;
      }
      try {
        await _synchronizeCachedSubject(currentSubject);
      } catch (recoveryError) {
        final recoveryStatus = connectionStatusFromError(recoveryError);
        if (recoveryStatus != null) {
          appConnectionStatusController.setStatus(recoveryStatus);
        }
      }
    } finally {
      _activeSubjectSyncInFlight = false;
    }
  }

  Future<void> _synchronizeCachedSubject(StudySubject currentSubject) async {
    final fetchRemoteSubject =
        debugFetchRemoteSubjectForSync ?? _fetchRemoteSubjectForSync;
    final remoteSubject = await fetchRemoteSubject(currentSubject.id);
    if (remoteSubject == null || activeSubject?.id != currentSubject.id) {
      return;
    }
    final synchronizedSubject = await Cache.synchronize(remoteSubject);
    if (activeSubject?.id != currentSubject.id) return;
    appConnectionStatusController.setStatus(AppConnectionStatus.healthy);
    updateActiveSubject(synchronizedSubject);
    if (appConnectionStatusController.status == AppConnectionStatus.healthy) {
      _cancelActiveSubjectSyncRetry();
    }
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
    _cancelActiveSubjectSyncRetry();
    _activeSubjectCacheSubscription?.cancel();
    _activeSubjectCacheSource = null;
    appConnectionStatusController.removeListener(_connectionStatusListener);
    super.dispose();
  }
}
