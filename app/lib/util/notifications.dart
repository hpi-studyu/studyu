import 'dart:async';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:studyu_app/screens/study/dashboard/dashboard.dart';
import 'package:studyu_core/core.dart';

import '../main.dart';
import '../routes.dart';
import '../screens/study/tasks/task_screen.dart';

class StudyNotifications {
  StudySubject subject;
  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;
  BuildContext context;
  final StreamController<ReceivedNotification> didReceiveLocalNotificationStream =
      StreamController<ReceivedNotification>.broadcast();
  final StreamController<String> selectNotificationStream = StreamController<String>.broadcast();
  String taskAlreadyCompleted;
  // do not launch notification action twice if user subscribes to a new study
  static bool wasNotificationActionHandled = false;

  /// Private constructor
  StudyNotifications._create(this.subject, this.context) {
    taskAlreadyCompleted = AppLocalizations.of(context).task_already_completed;
    // todo test permission requests
    _initNotificationsPlugin();
    _requestPermissions();
    _isAndroidPermissionGranted();
    _configureDidReceiveLocalNotificationSubject();
    _configureSelectNotificationSubject();
  }

  /// Public factory
  static Future<StudyNotifications> create(
    StudySubject activeSubject,
    BuildContext context,
  ) async {
    final notifications = StudyNotifications._create(activeSubject, context);
    final NotificationAppLaunchDetails notificationAppLaunchDetails = !kIsWeb && Platform.isLinux
        ? null
        : await notifications.flutterLocalNotificationsPlugin.getNotificationAppLaunchDetails();
    if ((notificationAppLaunchDetails?.didNotificationLaunchApp ?? false) && !wasNotificationActionHandled) {
      wasNotificationActionHandled = true;
      final selectedNotificationPayload = notificationAppLaunchDetails.notificationResponse.payload;
      notifications.handleNotificationResponse(selectedNotificationPayload);
    }
    return notifications;
  }

  Future<void> _isAndroidPermissionGranted() async {
    if (Platform.isAndroid) {
      //final bool granted =
      await flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
          .areNotificationsEnabled();
    }
  }

  Future<void> _requestPermissions() async {
    if (Platform.isIOS || Platform.isMacOS) {
      await flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>()
          ?.requestPermissions(
            alert: true,
            badge: true,
            sound: true,
          );
      await flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<MacOSFlutterLocalNotificationsPlugin>()
          ?.requestPermissions(
            alert: true,
            badge: true,
            sound: true,
          );
    } else if (Platform.isAndroid) {
      final AndroidFlutterLocalNotificationsPlugin androidImplementation = flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();

      //final bool granted =
      await androidImplementation?.requestPermission();
    }
  }

  void _configureDidReceiveLocalNotificationSubject() {
    didReceiveLocalNotificationStream.stream.listen((ReceivedNotification receivedNotification) async {
      await showDialog(
        context: context,
        builder: (BuildContext context) => CupertinoAlertDialog(
          title: receivedNotification.title != null ? Text(receivedNotification.title) : null,
          content: receivedNotification.body != null ? Text(receivedNotification.body) : null,
          actions: <Widget>[
            CupertinoDialogAction(
              isDefaultAction: true,
              onPressed: () async {
                Navigator.of(context, rootNavigator: true).pop();
                await Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (BuildContext context) => const DashboardScreen(),
                  ),
                );
              },
              child: const Text('Ok'),
            )
          ],
        ),
      );
    });
  }

  void _configureSelectNotificationSubject() {
    selectNotificationStream.stream.listen((String payload) async {
      handleNotificationResponse(payload);
    });
  }

  void _initNotificationsPlugin() {
    flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@drawable/ic_launcher');
    final DarwinInitializationSettings initializationSettingsDarwin = DarwinInitializationSettings(
      onDidReceiveLocalNotification: (
        int id,
        String title,
        String body,
        String payload,
      ) async {
        didReceiveLocalNotificationStream.add(
          ReceivedNotification(
            id: id,
            title: title,
            body: body,
            payload: payload,
          ),
        );
      },
    );
    const LinuxInitializationSettings initializationSettingsLinux = LinuxInitializationSettings(
      defaultActionName: 'Open notification',
    );
    final InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsDarwin,
      macOS: initializationSettingsDarwin,
      linux: initializationSettingsLinux,
    );
    flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (NotificationResponse notificationResponse) {
        switch (notificationResponse.notificationResponseType) {
          case NotificationResponseType.selectedNotification:
            selectNotificationStream.add(notificationResponse.payload);
            break;
          case NotificationResponseType.selectedNotificationAction:
            /*if (notificationResponse.actionId == navigationActionId) {
              selectNotificationStream.add(notificationResponse.payload);
            }*/
            break;
        }
      },
      onDidReceiveBackgroundNotificationResponse: notificationTapBackground,
    );
  }

  Future handleNotificationResponse(String taskId) async {
    final nowDt = DateTime.now();
    final now = StudyUTimeOfDay.fromDateTime(nowDt);
    TimedTask taskToRun;
    // figure out which TimedTask corresponds to the given taskId
    // Attention: If there are multiple tasks with overlapping completionPeriods
    // this might select the wrong task instance!
    // todo this needs refactoring if periodIds are directly passed to the notification
    for (final Task task in subject.study.taskList) {
      if (task.id == taskId) {
        for (final CompletionPeriod cp in task.schedule.completionPeriods) {
          if (cp.contains(now) /*|| kDebugMode*/) {
            taskToRun = TimedTask(task, cp);
          }
        }
      }
    }
    final completed = subject.isTimedTaskFinished(
      taskToRun.task.id,
      taskToRun.completionPeriod,
      nowDt,
    );
    if (taskToRun != null) {
      if (!completed /*|| !kDebugMode*/) {
        navigatorKey.currentState.push(
          MaterialPageRoute(
            builder: (_) => TaskScreen(timedTask: taskToRun),
          ),
        );
      } else {
        navigatorKey.currentState.push(
          MaterialPageRoute(
            builder: (_) => DashboardScreen(error: taskAlreadyCompleted),
          ),
        );
      }
    } else {
      navigatorKey.currentState.push(
        MaterialPageRoute(
          builder: (_) => const DashboardScreen(error: 'Task could not be found'),
        ),
      );
    }
  }
}

class ReceivedNotification {
  ReceivedNotification({
    this.id,
    this.title,
    this.body,
    this.payload,
  });

  final int id;
  final String title;
  final String body;
  final String payload;
}
