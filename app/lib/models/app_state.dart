import 'package:flutter/material.dart';
import 'package:studyu_app/util/app_analytics.dart';
import 'package:studyu_app/util/cache.dart';
import 'package:studyu_app/util/notifications.dart';
import 'package:studyu_app/util/schedule_notifications.dart';
import 'package:studyu_core/core.dart';
import 'package:studyu_flutter_common/studyu_flutter_common.dart';

class AppState with ChangeNotifier {
  Study? selectedStudy;
  List<Intervention>? selectedInterventions;
  StudySubject? activeSubject;
  String? inviteCode;
  List<String>? preselectedInterventionIds;
  StudyNotifications? studyNotifications;
  bool isPreview = false;
  late AppAnalytics analytics;

  /// Debug mode for study progression (enables Next Day button in release builds)
  bool _isDebugModeEnabled = false;

  /// Flag indicating whether the participant's progress should be tracked
  ///
  /// We always track the participant's progress except when the study is
  /// being viewed in test/preview mode while already launched (to avoid
  /// mixing results from test users with actual participants)
  bool get trackParticipantProgress => !(isPreview && selectedStudy!.isRunning);

  /// Debug mode getter
  bool get isDebugModeEnabled => _isDebugModeEnabled;

  AppState();

  void init(BuildContext context) {
    scheduleNotifications(context);
    analytics.initAdvanced();
    initCache();
    initDebugMode();
  }

  Future<void> initDebugMode() async {
    const String keyDebugModeEnabled = 'debug_mode_enabled';
    _isDebugModeEnabled = await SecureStorage.readBool(keyDebugModeEnabled) ?? false;
    notifyListeners();
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

  /// Debug mode setter
  Future<void> setDebugModeEnabled(bool enabled) async {
    const String keyDebugModeEnabled = 'debug_mode_enabled';
    await SecureStorage.write(keyDebugModeEnabled, enabled.toString());
    _isDebugModeEnabled = enabled;
    notifyListeners();
  }
}
