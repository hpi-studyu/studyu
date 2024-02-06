import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:flutter_web_plugins/url_strategy.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:studyu_app/routes.dart';
import 'package:studyu_app/util/app_analytics.dart';
import 'package:studyu_core/core.dart';
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
  AppConfig? appConfig;
  String initialRoute = Routes.loading;
  try {
    appConfig = await AppConfig.getAppConfig();
  } catch (error) {
    // device could be offline
  }

  if (appConfig != null && await isAppOutdated(appConfig)) {
    initialRoute = Routes.appOutdated;
  }

  await AppAnalytics.init();
  if (!kDebugMode && AppAnalytics.isUserEnabled) {
    AppAnalytics.start(appConfig, MyApp(queryParameters, appConfig, initialRoute: initialRoute));
  } else {
    runApp(MyApp(queryParameters, appConfig, initialRoute: initialRoute));
  }
}

/// Checks major and minor version of the app against the minimum version required by the backend
/// Returns true if the app is outdated
Future<bool> isAppOutdated(AppConfig appConfig) async {
  PackageInfo packageInfo = await PackageInfo.fromPlatform();
  final appVersion = packageInfo.version;
  final appVersionParts = appVersion.split('.');
  final minVersionParts = appConfig.appMinVersion.split('.');

  final appVersionMajor = int.parse(appVersionParts[0]);
  final appVersionMinor = int.parse(appVersionParts[1]);

  final minVersionMajor = int.parse(minVersionParts[0]);
  final minVersionMinor = int.parse(minVersionParts[1]);

  return appVersionMajor < minVersionMajor || (appVersionMajor == minVersionMajor && appVersionMinor < minVersionMinor);
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
