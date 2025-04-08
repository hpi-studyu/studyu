import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:package_info_plus/package_info_plus.dart';
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
  static Future<void> showDebugScreen(BuildContext context) async {
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
    final packageInfo = await PackageInfo.fromPlatform();
    final versionString =
        'Version: ${packageInfo.version} - ${packageInfo.buildNumber}';
    if (!context.mounted) return;
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const SelectableText(
          'Debug Screen',
        ),
        content: Column(
          children: [
            Text(versionString),
            ElevatedButton(
              onPressed: () {
                AppConfig.getAppContact().then((value) {
                  final Uri emailLaunchUri = Uri(
                    scheme: 'mailto',
                    path: value.email,
                    queryParameters: {
                      'subject': '[StudyU] Debug Information',
                      'body': 'version: $versionString\n'
                          'ignoreBatteryOptimizations: ${ignoreBatteryOptimizations ?? 'null'}\n'
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
            if (context.read<AppState>().studyNotifications != null)
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
                            Navigator.of(context).pop();
                            Navigator.of(context).pop();
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'App reset successfully! Please restart the app.',
                                ),
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
    final studyNotifications = context.read<AppState>().studyNotifications;
    if (studyNotifications == null) {
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Notifications are not initialized yet. Please start a study and open this through the about section.',
          ),
        ),
      );
      return;
    }
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
