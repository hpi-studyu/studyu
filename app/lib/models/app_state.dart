import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:studyu_app/util/app_analytics.dart';
import 'package:studyu_app/util/notifications.dart';
import 'package:studyu_app/util/cache.dart';
import 'package:studyu_app/util/schedule_notifications.dart';
import 'package:studyu_core/core.dart';

class AppState with ChangeNotifier {
  AppConfig? appConfig;
  Study? selectedStudy;
  List<Intervention>? selectedInterventions;
  StudySubject? activeSubject;
  String? inviteCode;
  List<String>? preselectedInterventionIds;
  StudyNotifications? studyNotifications;
  bool isPreview = false;
  late AppAnalytics analytics;

  /// Flag indicating whether the participant's progress should be tracked
  ///
  /// We always track the participant's progress except when the study is
  /// being viewed in test/preview mode while already launched (to avoid
  /// mixing results from test users with actual participants)
  bool get trackParticipantProgress => !(isPreview && selectedStudy!.isRunning);

  AppState(this.appConfig) {
    Connectivity().onConnectivityChanged.listen((ConnectivityResult result) async {
      try {
        appConfig = await AppConfig.getAppConfig();
      } catch (error) {
        // Still offline
      }
    });
  }

  void init(BuildContext context) {
    scheduleNotifications(context);
    // Analytics.addBreadcrumb(category: 'waypoint', message: 'Subject retrieved -> dashboard');
    analytics.initAdvanced();
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
    if (activeSubject!.study.id == study.id) {
      activeSubject!.study = study;
    }
    notifyListeners();
  }

  void leaveStudy() {
    selectedStudy = null;
    selectedInterventions = null;
    activeSubject = null;
    inviteCode = null;
    preselectedInterventionIds = null;
    studyNotifications = null;
  }
}
