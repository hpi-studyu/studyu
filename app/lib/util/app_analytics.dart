import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:sentry_logging/sentry_logging.dart';
import 'package:studyu_app/app.dart';
import 'package:studyu_app/models/app_state.dart';
import 'package:studyu_core/core.dart';
import 'package:studyu_flutter_common/studyu_flutter_common.dart';

import 'cache.dart';

class AppAnalytics /*extends Analytics*/ {
  static bool? _userEnabled;

  /// Checks if the user has allowed us to use analytic features
  static const String keyAnalyticsUserEnable = 'analytics_user_enable';

  /// Stores the [StudyUAnalytics] settings in the cache;
  final BuildContext context;
  late AppState state;
  StudySubject? subject;

  AppAnalytics(this.context) {
    state = context.read<AppState>();
    subject = state.activeSubject;
  }

  static Future<void> init() async {
    if (_userEnabled == null) {
      _userEnabled = await SecureStorage.readBool(keyAnalyticsUserEnable);
      // analytics is enabled by default
      _userEnabled ??= true;
    }
  }

  static Future<void> start(AppConfig? appConfig, MyApp myApp) async {
    StudyUAnalytics? studyUAnalytics;
    if (appConfig == null ||
        appConfig.analytics != null && appConfig.analytics!.dsn.isEmpty) {
      final cachedAnalytics = (await Cache.loadAnalytics());
      if (cachedAnalytics != null) {
        studyUAnalytics = cachedAnalytics;
      }
    } else {
      studyUAnalytics = appConfig.analytics;
    }

    if (studyUAnalytics == null || !studyUAnalytics.enabled) {
      runApp(myApp);
      return;
    }
    await SentryFlutter.init((options) {
      options.dsn = studyUAnalytics!.dsn;
      // Set tracesSampleRate to 1.0 to capture 100% of transactions for performance monitoring.
      // We recommend adjusting this value in production.
      options.tracesSampleRate = studyUAnalytics.samplingRate ?? 1.0;
      options.addIntegration(LoggingIntegration());
    }, appRunner: () => runApp(myApp));
    Cache.storeAnalytics(StudyUAnalytics(
      studyUAnalytics.enabled,
      studyUAnalytics.dsn,
      studyUAnalytics.samplingRate,
    ));
  }

  static get isUserEnabled {
    return _userEnabled;
  }

  static void setEnabled(bool newEnabled) async {
    await SecureStorage.write(keyAnalyticsUserEnable, newEnabled.toString());
    if (!newEnabled) {
      // a restart of the app will be necessary to enable sentry again
      Sentry.close();
    }
    _userEnabled = newEnabled;
  }

  Future<void> initBasic() async {
    Sentry.configureScope(
      (scope) async {
        final basicContext = {
          'selectedStudyObjectId': await getActiveSubjectId(),
          'isPreview': state.isPreview,
          'storedEmail': await getFakeUserEmail(),
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
