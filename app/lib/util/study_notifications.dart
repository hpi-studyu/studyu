import 'package:flutter/widgets.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:provider/provider.dart';
import 'package:studyu_core/core.dart';
import 'package:timezone/timezone.dart' as tz;

import '../models/app_state.dart';

extension Reminders on FlutterLocalNotificationsPlugin {
  // todo we should pass TimedTasks to this method instead of Tasks
  // to open the exact task instance when the notification is clicked.
  // This will break backwards compatibility for older databases!
  Future<int> scheduleReminderForDate(
    BuildContext context,
    int id,
    Task task,
    DateTime date,
    NotificationDetails notificationDetails,
  ) async {
    var currentId = id;
    for (final reminder in task.schedule.reminders) {
      if (date.isSameDate(DateTime.now()) && !StudyUTimeOfDay(hour: date.hour, minute: date.minute).earlierThan(reminder)
          || task.title.isEmpty ?? true) {
        break;
      }
      // unlock time:  ${task.schedule.completionPeriods.firstWhere((cp) => cp.unlockTime.earlierThan(reminder)).lockTime}
      final reminderTime = tz.TZDateTime(tz.local, date.year, date.month, date.day, reminder.hour, reminder.minute);
      zonedSchedule(
        currentId,
        task.title,
        '${AppLocalizations.of(context).study_notification_body}',
        reminderTime,
        notificationDetails,
        payload: task.id,
        uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.wallClockTime,
        androidAllowWhileIdle: true,
      );
      // DEBUG
      if (currentId == 0) {
        await show(
          /*******************/
          currentId,
          task.title,
          '${AppLocalizations.of(context).study_notification_body}',
          /*******************/
          notificationDetails,
          payload: task.id,
        );
      }
      // print('Scheduled Notification #$currentId: ${task.title}, $reminderTime, $notificationDetails, ${task.id}');
      currentId++;
    }
    return currentId;
  }
}

Future<void> scheduleNotifications(BuildContext context) async {
  final appState = context.read<AppState>();
  const androidPlatformChannelSpecifics = AndroidNotificationDetails('0', 'StudyU');
  const notificationDetails = NotificationDetails(android: androidPlatformChannelSpecifics);

  final subject = appState.activeSubject;
  final notificationsPlugin = await appState.notificationsPlugin;
  if (subject == null) return;

  await notificationsPlugin.cancelAll();

  final interventionTaskLists =
      subject.selectedInterventions?.map((intervention) => intervention.tasks)?.toList() ?? [];
  var interventionTasks = [];
  if (interventionTaskLists.isNotEmpty) {
    interventionTasks = interventionTaskLists.reduce((firstList, secondList) => [...firstList, ...secondList]) ?? [];
  }
  final tasks = [...subject.study.observations, ...interventionTasks,];
  if (tasks.isEmpty) return;

  final List<SendNotification> sendNotificationList = [];

  for (int index = 0; index <= 3; index++) {
    final date = DateTime.now().add(Duration(days: index));
    for (final observation in subject.study.observations) {
      sendNotificationList.add(SendNotification(observation, date, notificationDetails));
    }
    for (final intervention in subject.selectedInterventions ?? <Intervention>[]) {
      if (intervention.id == null || intervention.id != subject.getInterventionForDate(date)?.id) {
        continue;
      }
      for (final task in intervention.tasks) {
        sendNotificationList.add(SendNotification(task, date, notificationDetails));
      }
    }
  }
  var id = 0;
  for (final SendNotification notification in sendNotificationList) {
    final currentId = await notificationsPlugin.scheduleReminderForDate(
      context,
      id,
      notification.task,
      notification.date,
      notification.notificationDetails,
    );
    id = currentId;
  }
}

class SendNotification {
  SendNotification(
    this.task,
    this.date,
    this.notificationDetails,
  );

  final Task task;
  final DateTime date;
  final NotificationDetails notificationDetails;
}
