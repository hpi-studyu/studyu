import 'package:flutter/widgets.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:provider/provider.dart';
import 'package:studyu_core/core.dart';
import 'package:timezone/timezone.dart' as tz;

import '../models/app_state.dart';
import 'notifications.dart';

extension Reminders on FlutterLocalNotificationsPlugin {
  // todo we should pass TimedTasks to this method instead of Tasks
  // to open the exact task instance when the notification is clicked.
  // This will break backwards compatibility for older databases!
  Future<int> scheduleReminderForDate(
    int id,
    String body,
    Task task,
    DateTime date,
    NotificationDetails notificationDetails,
  ) async {
    var currentId = id;
    for (final reminder in task.schedule.reminders) {
      if (date.isSameDate(DateTime.now()) &&
          !StudyUTimeOfDay(hour: date.hour, minute: date.minute).earlierThan(reminder)) {
        break;
      }
      // unlock time:  ${task.schedule.completionPeriods.firstWhere((cp) => cp.unlockTime.earlierThan(reminder)).lockTime}
      final reminderTime = tz.TZDateTime(tz.local, date.year, date.month, date.day, reminder.hour, reminder.minute);
      zonedSchedule(
        currentId,
        task.title,
        body,
        reminderTime,
        notificationDetails,
        payload: task.id,
        uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.wallClockTime,
        androidAllowWhileIdle: true,
      );
      // DEBUG
      /*if (currentId == 0 || currentId == 1 || currentId == 2) {
        await show(
          /*******************/
          currentId,
          task.title,
          body,
          /*******************/
          notificationDetails,
          payload: task.id,
        );
      }*/
      // print('Scheduled Notification #$currentId: ${task.title}, $reminderTime, $notificationDetails, ${task.id}');
      currentId++;
    }
    return currentId;
  }
}

Future<void> scheduleNotifications(BuildContext context) async {
  final appState = context.read<AppState>();
  final subject = appState.activeSubject;
  final studyNotifications =
      context.read<AppState>().studyNotifications ?? await StudyNotifications.create(subject, context);

  final notificationsPlugin = studyNotifications.flutterLocalNotificationsPlugin;
  await notificationsPlugin.cancelAll();

  String body;
  if (context.mounted) body = AppLocalizations.of(context).study_notification_body;

  const androidPlatformChannelSpecifics = AndroidNotificationDetails('0', 'StudyU');
  const notificationDetails = NotificationDetails(android: androidPlatformChannelSpecifics);

  final interventionTaskLists =
      subject.selectedInterventions?.map((intervention) => intervention.tasks)?.toList() ?? [];
  var interventionTasks = [];
  if (interventionTaskLists.isNotEmpty) {
    interventionTasks = interventionTaskLists.reduce((firstList, secondList) => [...firstList, ...secondList]) ?? [];
  }
  final tasks = [
    ...subject.study.observations,
    ...interventionTasks,
  ];
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
        if (task.title != null) {
          sendNotificationList.add(SendNotification(task, date, notificationDetails));
        }
      }
    }
  }
  var id = 0;
  for (final SendNotification notification in sendNotificationList) {
    final currentId = await notificationsPlugin.scheduleReminderForDate(
      id,
      body,
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
