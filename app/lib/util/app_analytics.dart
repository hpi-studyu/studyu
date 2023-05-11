import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:studyu_app/models/app_state.dart';
import 'package:studyu_core/core.dart';
import 'package:studyu_flutter_common/studyu_flutter_common.dart';

class AppAnalytics {
  static bool? _enabled;
  static const String keyAnalytics = 'analytics';
  final BuildContext context;
  late AppState state;
  StudySubject? subject;

  AppAnalytics(this.context) {
    state = context.read<AppState>();
    subject = state.activeSubject;
  }

  static Future<void> init() async {
    if (_enabled == null) {
      final prefs = await SharedPreferences.getInstance();
      _enabled = prefs.get(keyAnalytics) as bool?;
      // analysis is enabled by default
      _enabled ??= true;
    }
  }

  static get isEnabled {
    return _enabled;
  }

  static void setEnabled(bool newEnabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(keyAnalytics, newEnabled);
    if (!newEnabled) {
      // a restart of the app will be necessary to enable sentry again
      Sentry.close();
    }
    _enabled = newEnabled;
  }

  Future<void> initBasic() async {
    Sentry.configureScope(
      (scope) async {
        final basicContext = {
          'selectedStudyObjectId': await getActiveSubjectId(),
          'isPreview': state.isPreview,
          'sharedPrefsEmail': await getFakeUserEmail(),
        };
        scope.setContexts('basicState', basicContext);
      },
    );
  }

  void initAdvanced() {
    Sentry.configureScope((scope) {
      scope.setUser(SentryUser(
        id: subject!.userId,
      ));
      final advancedContext = {
        'subjectId': subject!.id,
        'studyId': state.selectedStudy!.id,
        'subject': subject.toString(),
        'selectedStudy': state.selectedStudy.toString(),
      };
      scope.setContexts('advancedState', advancedContext);
    });
  }
}
