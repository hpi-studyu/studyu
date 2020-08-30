import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:studyou_core/models/models.dart';
import 'package:studyou_core/queries/queries.dart';

import '../../models/app_state.dart';
import '../../routes.dart';
import '../../util/localization.dart';
import '../../util/notifications.dart';
import '../study/report/report_details.dart';
import '../study/tasks/task_screen.dart';

class LoadingScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _LoadingScreenState();
}

class _LoadingScreenState extends State<LoadingScreen> {
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    initStudy();
  }

  Future<void> initStudy() async {
    final model = context.read<AppState>()..activeStudy = ParseUserStudy();
    final prefs = await SharedPreferences.getInstance();
    final selectedStudyObjectId = prefs.getString(UserQueries.selectedStudyObjectIdKey);
    print('Selected study: $selectedStudyObjectId');
    final notificationInit = initNotifications();
    if (selectedStudyObjectId == null) {
      if (await UserQueries.isUserLoggedIn()) {
        Navigator.pushReplacementNamed(context, Routes.studySelection);
        return;
      }
      Navigator.pushReplacementNamed(context, Routes.welcome);
      return;
    }

    final userStudy = await StudyQueries.getUserStudy(selectedStudyObjectId);
    if (userStudy != null) {
      model.activeStudy = userStudy;
      if (userStudy.completedStudy) {
        Navigator.pushReplacement(context, ReportDetailsScreen.routeFor(reportStudy: userStudy));
      } else {
        notificationInit.then((value) => scheduleStudyNotifications(context));
      }
      Navigator.pushReplacementNamed(context, Routes.dashboard);
    } else {
      Navigator.pushReplacementNamed(context, Routes.welcome);
    }
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
            onPressed: () async {
              Navigator.of(context, rootNavigator: true).pop();
              /*await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => SecondScreen(payload),
                ),
              );*/
            },
            child: Text('Ok'),
          )
        ],
      ),
    );
  }

  Future selectNotification(String taskId) async {
    if (taskId != null) {
      await Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => TaskScreen(
                  task: null,
                  taskId: taskId,
                )),
      );
    }
  }

  Future<void> initNotifications() async {
    final flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
    final initializationSettingsAndroid = AndroidInitializationSettings('app_icon');
    final initializationSettingsIOS =
        IOSInitializationSettings(onDidReceiveLocalNotification: onDidReceiveLocalNotification);
    final initializationSettings = InitializationSettings(initializationSettingsAndroid, initializationSettingsIOS);
    await flutterLocalNotificationsPlugin.initialize(initializationSettings, onSelectNotification: selectNotification);
    context.read<AppState>().notificationsPlugin = flutterLocalNotificationsPlugin;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '${Nof1Localizations.of(context).translate('loading')}...',
                style: Theme.of(context).textTheme.headline4,
              ),
              CircularProgressIndicator(),
            ],
          ),
        ),
      ),
    );
  }
}
