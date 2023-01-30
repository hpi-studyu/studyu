import 'package:flutter/widgets.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:provider/provider.dart';
import 'package:studyu_core/core.dart';
import 'package:timezone/timezone.dart' as tz;

import '../models/app_state.dart';

extension Reminders on FlutterLocalNotificationsPlugin {
  // todo we should pass TimedTasks to this method instead of Tasks
  // to open the exact task instance when the notification is clicked.
  // This will break backwards compatibility for older databases!
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
      zonedSchedule(
        id,
        task.title,
        'A new task awaits your attention until ${task.schedule.completionPeriods.firstWhere((cp) => cp.unlockTime.earlierThan(reminder))}',
        reminderTime,
        notificationDetails,
        payload: task.id,
        uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.wallClockTime,
        androidAllowWhileIdle: true,
      );
      // print('Notification #$id: ${task.title}, $reminderTime, $notificationDetails, ${task.id}');
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
  for (int index = 0; index <= 3; index++) {
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
