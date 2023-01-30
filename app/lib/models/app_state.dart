import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:studyu_app/screens/study/dashboard/dashboard.dart';
import 'package:studyu_core/core.dart';

import '../screens/study/tasks/task_screen.dart';

class AppState {
  Study selectedStudy;
  List<Intervention> selectedInterventions;
  StudySubject activeSubject;
  String inviteCode;
  List<String> preselectedInterventionIds;
  FlutterLocalNotificationsPlugin _notificationsPlugin;

  /// Context used for FlutterLocalNotificationsPlugin
  BuildContext context;

  Future<FlutterLocalNotificationsPlugin> get notificationsPlugin async =>
      _notificationsPlugin ??= await initNotificationsPlugin();

  AppState(this.context);

  Future<FlutterLocalNotificationsPlugin> initNotificationsPlugin() async {
    final flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
    const AndroidInitializationSettings initializationSettingsAndroid =
    AndroidInitializationSettings('app_icon');
    final DarwinInitializationSettings initializationSettingsDarwin = DarwinInitializationSettings(onDidReceiveLocalNotification: onDidReceiveLocalNotification);
    const LinuxInitializationSettings initializationSettingsLinux = LinuxInitializationSettings(defaultActionName: 'Open notification');
    final InitializationSettings initializationSettings = InitializationSettings(
        android: initializationSettingsAndroid,
        iOS: initializationSettingsDarwin,
        macOS: initializationSettingsDarwin,
        linux: initializationSettingsLinux,
    );
    await flutterLocalNotificationsPlugin.initialize(initializationSettings,
        onDidReceiveNotificationResponse: onDidReceiveNotificationResponse,
    );
  return flutterLocalNotificationsPlugin;
  }

  Future<void> onDidReceiveLocalNotification(int id, String title, String body, String payload) async {
    showDialog(
      context: context,
      builder: (BuildContext context) => CupertinoAlertDialog(
        title: Text(title),
        content: Text(body),
        actions: [
          CupertinoDialogAction(
            isDefaultAction: true,
            child: const Text('Ok'),
            onPressed: () async {
              Navigator.of(context, rootNavigator: true).pop();
            },
          )
        ],
      ),
    );
  }

  Future onDidReceiveNotificationResponse(NotificationResponse notificationResponse) async {
    final String taskId = notificationResponse.payload;
    if (notificationResponse.payload != null) {
      debugPrint('notification payload: $taskId');
    }
    final now = StudyUTimeOfDay.now();
    TimedTask taskToRun;
    for (final Task task in selectedStudy.taskList) {
      if (task.id == taskId) {
        for (final CompletionPeriod cp in task.schedule.completionPeriods) {
          if (cp.contains(now)) {
            taskToRun = TimedTask(task, cp);
          }
        }
      }
    }
    if (taskToRun != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) =>
              TaskScreen(
                timedTask: taskToRun,
              ),
        ),
      );
    } else {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) =>
              DashboardScreen(),
        ),
      );
    }
  }
}
