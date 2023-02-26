import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:provider/provider.dart';
import 'package:studyu_core/core.dart';
import 'package:timezone/timezone.dart' as tz;

import '../models/app_state.dart';
import 'notifications.dart';

extension Reminders on FlutterLocalNotificationsPlugin {
  Future<int> scheduleReminderForDate(
      int id, String body, StudyNotification studyNotification, NotificationDetails notificationDetails) async {
    var currentId = id;
    final task = studyNotification.taskInstance.task;
    final date = studyNotification.date;
    for (final reminder in task.schedule.reminders) {
      // unlock time:  ${task.schedule.completionPeriods.firstWhere((cp) => cp.unlockTime.earlierThan(reminder)).lockTime}
      final reminderTime = tz.TZDateTime(tz.local, date.year, date.month, date.day, reminder.hour, reminder.minute);
      if (date.isSameDate(DateTime.now()) &&
          !StudyUTimeOfDay(hour: date.hour, minute: date.minute).earlierThan(reminder, exact: true)) {
        String debugStr = 'Skipped Notification #$currentId: $reminderTime, ${task.title}, ${studyNotification.taskInstance.id}';
        StudyNotifications.scheduledNotificationsDebug += '\n\n$debugStr';
        if (StudyNotifications.debug) {
          print(debugStr);
        }
        continue;
      }
      zonedSchedule(
        currentId,
        task.title,
        body,
        reminderTime,
        notificationDetails,
        payload: studyNotification.taskInstance.id,
        uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.wallClockTime,
        androidAllowWhileIdle: true,
      );
      // DEBUG: Show test notifications
      /*if (StudyNotifications.debug && (currentId == 0 || currentId == 1 || currentId == 2)) {
        await show(
          /*******************/
          currentId,
          task.title,
          body,
          /*******************/
          notificationDetails,
          payload: studyNotification.taskInstance.id,
        );
      }*/
      // DEBUG: List scheduled notifications
      String debugStr = 'Scheduled Notification #$currentId: $reminderTime, ${task.title}, ${studyNotification.taskInstance.id}';
      StudyNotifications.scheduledNotificationsDebug += '\n\n$debugStr';
      if (StudyNotifications.debug) {
        print(debugStr);
      }
      currentId++;
    }
    return currentId;
  }
}

Future<void> scheduleNotifications(BuildContext context) async {
  StudyNotifications.scheduledNotificationsDebug = DateTime.now().toString();
  if (StudyNotifications.debug) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Schedule Notifications'),
      ),
    );
  }
  // Notifications not supported on web
  if (kIsWeb) return;
  final appState = context.read<AppState>();
  final subject = appState.activeSubject;
  final body = AppLocalizations.of(context).study_notification_body;
  final studyNotifications =
      context.read<AppState>().studyNotifications ?? await StudyNotifications.create(subject, context);

  final notificationsPlugin = studyNotifications.flutterLocalNotificationsPlugin;
  await notificationsPlugin.cancelAll();

  const notificationDetails = NotificationDetails(android: AndroidNotificationDetails('0', 'StudyU'));
  final List<StudyNotification> studyNotificationList = [];

  for (int index = 0; index <= 3; index++) {
    final date = DateTime.now().add(Duration(days: index));
    studyNotificationList.addAll(_buildNotificationList(subject, date, subject.study.observations));
    for (final intervention in subject.selectedInterventions) {
      if (intervention.id == null || intervention.id != subject.getInterventionForDate(date)?.id) {
        continue;
      }
      studyNotificationList.addAll(_buildNotificationList(subject, date, intervention.tasks));
    }
  }
  var id = 0;
  for (final StudyNotification notification in studyNotificationList) {
    final currentId = await notificationsPlugin.scheduleReminderForDate(id, body, notification, notificationDetails);
    id = currentId;
  }
}

List<StudyNotification> _buildNotificationList(StudySubject subject, DateTime date, List<Task> tasks) {
  List<StudyNotification> taskNotifications = [];
  for (Task task in tasks) {
    if (task.title == null || task.title.isEmpty) return [];
    for (final completionPeriod in task.schedule.completionPeriods) {
      TaskInstance taskInstance = TaskInstance(task, completionPeriod.id);
      if (!subject.completedTaskInstanceForDay(task.id, taskInstance.completionPeriod, date)) {
        taskNotifications.add(StudyNotification(taskInstance, date));
      }
    }
  }
  return taskNotifications;
}

class StudyNotification {
  StudyNotification(
    this.taskInstance,
    this.date,
  );

  final TaskInstance taskInstance;
  final DateTime date;
}
