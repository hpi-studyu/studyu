import 'package:flutter/material.dart';
import 'package:studyu_app/util/cache.dart';
import 'package:studyu_app/util/notifications.dart';
import 'package:studyu_app/util/schedule_notifications.dart';
import 'package:studyu_core/core.dart';

class AppState with ChangeNotifier {
  Study? selectedStudy;
  List<Intervention>? selectedInterventions;
  StudySubject? activeSubject;
  String? inviteCode;
  List<String>? preselectedInterventionIds;
  StudyNotifications? studyNotifications;
  bool isPreview = false;
  bool hasAcceptedTerms = false;
  bool showRecoveryPhraseOnDashboard = false;

  String? pendingDeepLinkStudyId;
  String? pendingDeepLinkInviteCode;

  bool get hasPendingDeepLink =>
      pendingDeepLinkStudyId != null || pendingDeepLinkInviteCode != null;

  void setPendingDeepLink({
    required Study study,
    String? inviteCode,
    List<String>? preselectedInterventionIds,
  }) {
    pendingDeepLinkStudyId = inviteCode == null ? study.id : null;
    pendingDeepLinkInviteCode = inviteCode;
    selectedStudy = study;
    this.inviteCode = inviteCode;
    this.preselectedInterventionIds = preselectedInterventionIds;
    notifyListeners();
  }

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

  AppState();

  void init(BuildContext context) {
    scheduleNotifications(context);
    initCache();
  }

  void initCache() {
    activeSubject!.onSave.listen((StudySubject subject) async {
      await Cache.storeSubject(subject);
    });
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
}
