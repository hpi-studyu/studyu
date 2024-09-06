import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:studyu_app/models/app_state.dart';
import 'package:studyu_app/util/notifications.dart';
import 'package:studyu_app/util/schedule_notifications.dart';
import 'package:studyu_core/core.dart';
import 'package:studyu_flutter_common/studyu_flutter_common.dart';
import 'package:url_launcher/url_launcher.dart';

class DebugScreen {
  static void showDebugScreen(BuildContext context) {
    final studyNotifications = context.read<AppState>().studyNotifications;

    final pendingNotifications = studyNotifications != null
        ? studyNotifications.flutterLocalNotificationsPlugin
            .pendingNotificationRequests()
        : Future.value([]);

    final pendingNotificationsPlugin =
        FlutterLocalNotificationsPlugin().pendingNotificationRequests();

    bool? ignoreBatteryOptimizations;
    int? pendingNotificationRes;
    int? pendingNotificationsPluginRes;

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const SelectableText(
          'Debug Screen',
        ),
        content: Column(
          children: [
            ElevatedButton(
              onPressed: () {
                AppConfig.getAppContact().then((value) {
                  final Uri emailLaunchUri = Uri(
                    scheme: 'mailto',
                    path: value.email,
                    queryParameters: {
                      'subject': '[StudyU] Debug Information',
                      'body': 'ignoreBatteryOptimizations: ${ignoreBatteryOptimizations ?? 'null'}\n'
                          'pendingNotificationsNumber: ${pendingNotificationRes ?? 'null'}\n'
                          'pendingNotificationsPluginNumber: ${pendingNotificationsPluginRes ?? 'null'}\n'
                          'scheduledNotificationsDebug: ${StudyNotifications.scheduledNotificationsDebug}',
                    },
                  );
                  launchUrl(emailLaunchUri);
                });
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).primaryColor,
              ),
              child: const Text('Send debug information via email'),
            ),
            ElevatedButton(
              onPressed: () {
                testNotification(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.secondary,
              ),
              child: const Text('Receive test notification'),
            ),
            ElevatedButton(
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (_) => AlertDialog(
                    title: const Text('Reset App?'),
                    content: const Text(
                      'This will delete all data and reset the app.',
                    ),
                    actions: <Widget>[
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        child: const Text('Cancel'),
                      ),
                      TextButton(
                        onPressed: () async {
                          await _deleteCacheDir();
                          await _deleteAppDir();
                          await SecureStorage.deleteAll();
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('App reset successfully'),
                              ),
                            );
                            await Future.delayed(const Duration(seconds: 1));
                            await SystemChannels.platform
                                .invokeMethod('SystemNavigator.pop');
                          }
                        },
                        child: const Text('Reset'),
                      ),
                    ],
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.error,
              ),
              child: const Text('Reset App'),
            ),
            FutureBuilder<bool>(
              future: receivePermission(),
              builder: (
                context,
                AsyncSnapshot<bool> snapshot,
              ) {
                if (snapshot.hasData) {
                  final String data =
                      "ignoreBatteryOptimizations: ${snapshot.data}";
                  ignoreBatteryOptimizations = snapshot.data;
                  return Text(data);
                } else {
                  return const CircularProgressIndicator();
                }
              },
            ),
            FutureBuilder<List>(
              future: pendingNotifications,
              builder: (
                context,
                AsyncSnapshot<List> snapshot,
              ) {
                if (snapshot.hasData) {
                  pendingNotificationRes = snapshot.data!.length;
                  return Text(
                    'Number of Pending Notifications: $pendingNotificationRes',
                  );
                } else if (snapshot.hasError) {
                  return Text(
                    'Pending Notifications: Error: ${snapshot.error}',
                  );
                } else {
                  return const CircularProgressIndicator();
                }
              },
            ),
            FutureBuilder<List<PendingNotificationRequest>>(
              future: pendingNotificationsPlugin,
              builder: (
                context,
                AsyncSnapshot<List<PendingNotificationRequest>> snapshot,
              ) {
                if (snapshot.hasData) {
                  pendingNotificationsPluginRes = snapshot.data!.length;
                  return Text(
                    'Local Notifications Plugin Number of Pending Notifications: $pendingNotificationsPluginRes',
                  );
                } else if (snapshot.hasError) {
                  return Text(
                    'Pending Notifications Plugin: Error: ${snapshot.error}',
                  );
                } else {
                  return const CircularProgressIndicator();
                }
              },
            ),
            const Text("Scheduled Notifications:"),
            SelectableText(
              StudyNotifications.scheduledNotificationsDebug ?? 'No data',
            ),
          ],
        ),
        scrollable: true,
      ),
    );
  }

  static Future<void> testNotification(BuildContext context) async {
    // Notifications not supported on web
    if (kIsWeb) return;
    final appState = context.read<AppState>();
    final studyNotifications = appState.studyNotifications;
    if (studyNotifications == null) return;
    await studyNotifications.flutterLocalNotificationsPlugin.show(
      /*******************/
      99,
      'StudyU Test Notification',
      'This notification confirms that you receive StudyU notifications',
      /*******************/
      notificationDetails,
    );
  }

  static Future<bool> receivePermission() async {
    return await Permission.ignoreBatteryOptimizations.request().isGranted;
  }

  static Future<void> _deleteCacheDir() async {
    final cacheDir = await getTemporaryDirectory();

    if (cacheDir.existsSync()) {
      cacheDir.deleteSync(recursive: true);
    }
  }

  static Future<void> _deleteAppDir() async {
    final appDir = await getApplicationSupportDirectory();
    if (appDir.existsSync()) {
      appDir.deleteSync(recursive: true);
    }
  }
}
