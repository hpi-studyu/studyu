import 'dart:async';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:studyu_app/main.dart';
import 'package:studyu_app/routes.dart';
import 'package:studyu_app/screens/study/dashboard/dashboard.dart';
import 'package:studyu_app/screens/study/tasks/task_screen.dart';
import 'package:studyu_core/core.dart';

class NotificationValidators {
  bool didNotificationLaunchApp = false;
  // do not launch notification action twice if user subscribes to a new study
  bool wasNotificationActionHandled = false;
  bool wasNotificationActionCompleted = false;

  NotificationValidators(
    this.didNotificationLaunchApp,
    this.wasNotificationActionHandled,
    this.wasNotificationActionCompleted,
  );
}

class StudyNotifications {
  StudySubject? subject;
  late FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;
  BuildContext context;
  final StreamController<ReceivedNotification>
      didReceiveLocalNotificationStream =
      StreamController<ReceivedNotification>.broadcast();
  final StreamController<String?> selectNotificationStream =
      StreamController<String?>.broadcast();
  // String? _taskCannotBeCompleted;

  static final NotificationValidators validator =
      NotificationValidators(false, false, false);

  static const bool debug = false; //kDebugMode;
  static String? scheduledNotificationsDebug;

  /// Private constructor
  StudyNotifications._create(this.subject, this.context) {
    // _taskCannotBeCompleted = AppLocalizations.of(context)!.task_cannot_be_completed;
    _initNotificationsPlugin();
    _requestPermissions();
    _isAndroidPermissionGranted();
    _configureDidReceiveLocalNotificationSubject();
    _configureSelectNotificationSubject();
  }

  /// Public factory
  static Future<StudyNotifications> create(
    StudySubject? activeSubject,
    BuildContext context,
  ) async {
    final notifications = StudyNotifications._create(activeSubject, context);
    final NotificationAppLaunchDetails? notificationAppLaunchDetails =
        !kIsWeb && Platform.isLinux
            ? null
            : await notifications.flutterLocalNotificationsPlugin
                .getNotificationAppLaunchDetails();
    StudyNotifications.validator.didNotificationLaunchApp =
        notificationAppLaunchDetails?.didNotificationLaunchApp ?? false;
    if (StudyNotifications.validator.didNotificationLaunchApp &&
        !StudyNotifications.validator.wasNotificationActionHandled) {
      StudyNotifications.validator.wasNotificationActionHandled = true;
      final selectedNotificationPayload =
          notificationAppLaunchDetails!.notificationResponse!.payload!;
      notifications.handleNotificationResponse(selectedNotificationPayload);
    }
    return notifications;
  }

  Future<void> _isAndroidPermissionGranted() async {
    if (Platform.isAndroid) {
      //final bool granted =
      await flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>()!
          .areNotificationsEnabled();
    }
  }

  Future<void> _requestPermissions() async {
    if (Platform.isIOS || Platform.isMacOS) {
      await flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<
              IOSFlutterLocalNotificationsPlugin>()
          ?.requestPermissions(
            alert: true,
            badge: true,
            sound: true,
          );
      await flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<
              MacOSFlutterLocalNotificationsPlugin>()
          ?.requestPermissions(
            alert: true,
            badge: true,
            sound: true,
          );
    } else if (Platform.isAndroid) {
      // todo look into this further if notifications are not received on Android
      final AndroidFlutterLocalNotificationsPlugin? androidImplementation =
          flutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>();

      /*final bool granted =*/ await androidImplementation
          ?.requestNotificationsPermission();

      final status = await Permission.ignoreBatteryOptimizations.status;
      if (status.isDenied) {
        if (await Permission.ignoreBatteryOptimizations.request().isGranted) {
          // print("Ignore battery optimization Permission is granted");
        } else {
          // print("Ignore battery optimization Permission is denied.");
        }
      }
    }
  }

  void _configureDidReceiveLocalNotificationSubject() {
    didReceiveLocalNotificationStream.stream
        .listen((ReceivedNotification receivedNotification) async {
      await showDialog(
        context: context,
        builder: (BuildContext context) => CupertinoAlertDialog(
          title: receivedNotification.title != null
              ? Text(receivedNotification.title!)
              : null,
          content: receivedNotification.body != null
              ? Text(receivedNotification.body!)
              : null,
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
            ),
          ],
        ),
      );
    });
  }

  void _configureSelectNotificationSubject() {
    selectNotificationStream.stream.listen((String? payload) async {
      handleNotificationResponse(payload!);
    });
  }

  void _initNotificationsPlugin() {
    flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@drawable/ic_notification');
    final DarwinInitializationSettings initializationSettingsDarwin =
        DarwinInitializationSettings(
      onDidReceiveLocalNotification: (
        int id,
        String? title,
        String? body,
        String? payload,
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
    const LinuxInitializationSettings initializationSettingsLinux =
        LinuxInitializationSettings(
      defaultActionName: 'Open notification',
    );
    final InitializationSettings initializationSettings =
        InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsDarwin,
      macOS: initializationSettingsDarwin,
      linux: initializationSettingsLinux,
    );
    flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse:
          (NotificationResponse notificationResponse) {
        switch (notificationResponse.notificationResponseType) {
          case NotificationResponseType.selectedNotification:
            selectNotificationStream.add(notificationResponse.payload);
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

  Future handleNotificationResponse(String taskInstanceId) async {
    final nowDt = DateTime.now();
    final taskToRun =
        TaskInstance.fromInstanceId(taskInstanceId, subject: subject);

    final completed = subject!.completedTaskInstanceForDay(
      taskToRun.task.id,
      taskToRun.completionPeriod,
      nowDt,
    );

    //if (taskToRun != null) {
    final isInsidePeriod =
        taskToRun.completionPeriod.contains(StudyUTimeOfDay.now());
    if (!completed && isInsidePeriod) {
      await navigatorKey.currentState!.push(
        MaterialPageRoute(
          builder: (_) => TaskScreen(taskInstance: taskToRun),
        ),
      );
      navigatorKey.currentState!
          .pushNamedAndRemoveUntil(Routes.loading, (_) => false);
      // todo error management after null safety
      /*} else {
        navigatorKey.currentState!.push(
          MaterialPageRoute(
            // todo change error "or not inside period"
            builder: (_) => DashboardScreen(error: _taskCannotBeCompleted),
          ),
        );
      }*/
    } else {
      navigatorKey.currentState!.push(
        // todo translate
        MaterialPageRoute(
          builder: (_) =>
              const DashboardScreen(error: 'Task could not be found'),
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

  final int? id;
  final String? title;
  final String? body;
  final String? payload;
}
