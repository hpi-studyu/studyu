import 'package:flutter/widgets.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:provider/provider.dart';
import 'package:studyou_core/models/models.dart' as models;

import '../models/app_state.dart';

extension Reminders on FlutterLocalNotificationsPlugin {
  void scheduleReminder(int id, models.Task task, NotificationDetails notificationDetails) {
    for (final taskSchedule in task.schedule) {
      switch (taskSchedule.type) {
        case models.FixedSchedule.scheduleType:
          final models.FixedSchedule fixedSchedule = taskSchedule;
          final now = DateTime.now();
          var add = 0;
          if (!models.Time(hour: now.hour, minute: now.minute).earlierThan(fixedSchedule.time)) {
            add++;
          }
          final reminderTime =
              DateTime(now.year, now.month, now.day, fixedSchedule.time.hour, fixedSchedule.time.minute)
                  .add(Duration(days: add));
          // TODO add body
          schedule(id, task.title, '', reminderTime, notificationDetails, payload: task.id);
      }
    }
  }
}

Future<void> scheduleStudyNotifications(BuildContext context) async {
  final appState = context.read<AppState>();
  final androidPlatformChannelSpecifics =
      AndroidNotificationDetails('0', 'StudyU main', 'The main StudyU notification channel.');
  final iOSPlatformChannelSpecifics = IOSNotificationDetails();
  final platformChannelSpecifics = NotificationDetails(androidPlatformChannelSpecifics, iOSPlatformChannelSpecifics);

  final study = appState.activeStudy;

  if (study != null) {
    final taskAmount = (study.observations?.length ?? 0) +
        (study.interventionSet.interventions
                ?.map((intervention) => intervention.tasks?.length ?? 0)
                ?.reduce((x, y) => x + y) ??
            0);
    print(taskAmount);
  }

  final task = context.read<AppState>().activeStudy?.observations?.firstWhere((e) => true, orElse: () => null);
  if (task != null) {
    await appState.notificationsPlugin.scheduleReminder(0, task, platformChannelSpecifics);
  }

  appState.notificationsPlugin.pendingNotificationRequests().then((value) => print(value.length));
}
