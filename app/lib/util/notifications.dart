import 'package:flutter/widgets.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:provider/provider.dart';
import 'package:studyu_core/core.dart';
import 'package:timezone/timezone.dart' as tz;

import '../models/app_state.dart';

extension Reminders on FlutterLocalNotificationsPlugin {
  Future<void> scheduleReminderForDate(
    int initialId,
    Task task,
    DateTime date,
    NotificationDetails notificationDetails,
  ) async {
    var id = initialId;
    for (final reminder in task.schedule.reminders) {
      if (date.isSameDate(DateTime.now()) &&
          !StudyUTimeOfDay(hour: date.hour, minute: date.minute).earlierThan(reminder)) {
        break;
      }

      final reminderTime = tz.TZDateTime(tz.local, date.year, date.month, date.day, reminder.hour, reminder.minute);
      // TODO add body
      zonedSchedule(
        id,
        task.title,
        '',
        reminderTime,
        notificationDetails,
        payload: task.id,
        uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.wallClockTime,
        androidAllowWhileIdle: true,
      );
      id++;
    }
  }
}

Future<void> scheduleNotifications(BuildContext context) async {
  final appState = context.read<AppState>();
  const androidPlatformChannelSpecifics = AndroidNotificationDetails('0', 'StudyU');
  const platformChannelSpecifics = NotificationDetails(android: androidPlatformChannelSpecifics);

  final subject = appState.activeSubject;
  final notificationsPlugin = await appState.notificationsPlugin;
  if (subject == null) return;

  final interventionTaskLists =
      subject.selectedInterventions?.map((intervention) => intervention.tasks)?.toList() ?? [];
  var interventionTasks = [];
  if (interventionTaskLists.isNotEmpty) {
    interventionTasks = interventionTaskLists.reduce((firstList, secondList) => [...firstList, ...secondList]) ?? [];
  }
  final tasks = [...subject.study.observations, ...interventionTasks,];
  if (tasks.isEmpty) return;

  var id = 0;
  for (int index; index <= 3; index++) {
    final date = DateTime.now().add(Duration(days: index));
    for (final observation in subject.study.observations) {
      notificationsPlugin.scheduleReminderForDate(
        id, observation, date, platformChannelSpecifics,
      );
      id += observation.schedule.reminders.length;
    }
    for (final intervention in subject.selectedInterventions ?? <Intervention>[]) {
      if (intervention.id == null || intervention.id != subject.getInterventionForDate(date)?.id) {
        if (intervention.tasks.isNotEmpty) {
          id += intervention.tasks.map((task) => task.schedule.reminders.length).reduce((a, b) => a + b);
        }
        continue;
      }
      for (final task in intervention.tasks) {
        notificationsPlugin.scheduleReminderForDate(id, task, date, platformChannelSpecifics);
        id += task.schedule.reminders.length;
      }
    }
  }
}
