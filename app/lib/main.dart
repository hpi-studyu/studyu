import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:flutter_web_plugins/url_strategy.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:sentry_logging/sentry_logging.dart';
import 'package:studyu_app/util/app_analytics.dart';
import 'package:studyu_flutter_common/studyu_flutter_common.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

import 'app.dart';

@pragma('vm:entry-point')
void notificationTapBackground(NotificationResponse notificationResponse) {
  // ignore: avoid_print
  print('notification(${notificationResponse.id}) action tapped: '
      '${notificationResponse.actionId} with'
      ' payload: ${notificationResponse.payload}');
  if (notificationResponse.input?.isNotEmpty ?? false) {
    // ignore: avoid_print
    print('notification action tapped with input: ${notificationResponse.input}');
  }
}

GlobalKey<NavigatorState> navigatorKey = GlobalKey(debugLabel: 'Main Navigator');

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await loadEnv();
  await _configureLocalTimeZone();
  final queryParameters = Uri.base.queryParameters;
  // Turn off the # in the URLs on the web
  usePathUrlStrategy();
  await AppAnalytics.init();

  if (!kDebugMode && AppAnalytics.isEnabled) {
    await SentryFlutter.init(
      (options) {
        options.dsn = 'https://afe6ec116e4b4096956eb109e1135f36@o4504554311188480.ingest.sentry.io/4504554316169216';
        // Set tracesSampleRate to 1.0 to capture 100% of transactions for performance monitoring.
        // We recommend adjusting this value in production.
        options.tracesSampleRate = 1.0;
        options.addIntegration(LoggingIntegration());
      },
      appRunner: () {
        runApp(MyApp(queryParameters));
      },
    );
  } else {
    runApp(MyApp(queryParameters));
  }
}

/// This is needed for flutter_local_notifications
Future<void> _configureLocalTimeZone() async {
  if (kIsWeb || Platform.isLinux) {
    return;
  }
  tz.initializeTimeZones();
  final String timeZoneName = await FlutterTimezone.getLocalTimezone();
  tz.setLocalLocation(tz.getLocation(timeZoneName));
}
