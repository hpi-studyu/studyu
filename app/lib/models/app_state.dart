import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:studyu_core/core.dart';

import '../screens/study/tasks/task_screen.dart';

class AppState {
  Study selectedStudy;
  List<Intervention> selectedInterventions;
  StudySubject activeSubject;
  String inviteCode;
  List<String> preselectedInterventionIds;
  FlutterLocalNotificationsPlugin _notificationsPlugin;
  bool isPreview = false;
  bool isPreviewSkipping = false;

  /// Context used for FlutterLocalNotificationsPlugin
  BuildContext context;

  Future<FlutterLocalNotificationsPlugin> get notificationsPlugin async =>
      _notificationsPlugin ??= await initNotificationsPlugin();

  AppState(this.context);

  Future<FlutterLocalNotificationsPlugin> initNotificationsPlugin() async {
    final flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
    const initializationSettingsAndroid = AndroidInitializationSettings('app_icon');
    final initializationSettingsIOS =
        IOSInitializationSettings(onDidReceiveLocalNotification: onDidReceiveLocalNotification);
    final initializationSettings =
        InitializationSettings(android: initializationSettingsAndroid, iOS: initializationSettingsIOS);
    await flutterLocalNotificationsPlugin.initialize(initializationSettings, onSelectNotification: selectNotification);
    return flutterLocalNotificationsPlugin;
  }

  Future onDidReceiveLocalNotification(int id, String title, String body, String payload) async {
    // display a dialog with the notification details, tap ok to go to another page
    showDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: Text(title),
        content: Text(body),
        actions: [
          CupertinoDialogAction(
            isDefaultAction: true,
            onPressed: () => Navigator.of(context, rootNavigator: true).pop(),
            child: const Text('Ok'),
          )
        ],
      ),
    );
  }

  Future selectNotification(String taskId) async {
    if (taskId != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => TaskScreen(
            task: null,
            taskId: taskId,
          ),
        ),
      );
    }
  }
}
