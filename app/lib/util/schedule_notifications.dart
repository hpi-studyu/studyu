import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:provider/provider.dart';
import 'package:studyu_app/models/app_state.dart';
import 'package:studyu_app/util/notifications.dart';
import 'package:studyu_core/core.dart';
import 'package:timezone/timezone.dart' as tz;

Future<int> scheduleReminderForDate(
  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin,
  int id,
  String body,
  StudyNotification studyNotification,
  NotificationDetails notificationDetails,
) async {
  var currentId = id;
  final task = studyNotification.taskInstance.task;
  final date = studyNotification.date;
  for (final reminder in task.schedule.reminders) {
    // unlock time:  ${task.schedule.completionPeriods.firstWhere((cp) => cp.unlockTime.earlierThan(reminder)).lockTime}
    final reminderTime = tz.TZDateTime(
      tz.local,
      date.year,
      date.month,
      date.day,
      reminder.hour,
      reminder.minute,
    );
    if (date.isSameDate(DateTime.now()) &&
        !StudyUTimeOfDay(hour: date.hour, minute: date.minute)
            .earlierThan(reminder, exact: true)) {
      /* final String debugStr = 'Skipped #$currentId: $reminderTime, ${task.title}, ${studyNotification.taskInstance.id}';
      // StudyNotifications.scheduledNotificationsDebug += '\n\n$debugStr';
      if (StudyNotifications.debug) {
        print(debugStr);
      } */
      continue;
    }

    // todo we do not support overlapping completion periods, since otherwise we cannot identify the origin of the reminder exactly
    // for now we just filter out all task instances where the reminder is outside of the completionPeriod
    if (!task.schedule.completionPeriods
        .where((element) => element.id == studyNotification.taskInstance.id)
        .single
        .contains(reminder)) {
      continue;
    }

    flutterLocalNotificationsPlugin.zonedSchedule(
      currentId,
      task.title,
      body,
      reminderTime,
      notificationDetails,
      payload: studyNotification.taskInstance.id,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.wallClockTime,
      // exactAllowWhileIdle only works if the exact alarm permission has been granted
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
    );
    // DEBUG: Show test notifications
    /*if (StudyNotifications.debug && (currentId == 0 || currentId == 1 || currentId == 2)) {
        await flutterLocalNotificationsPlugin.show(
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
    final String debugStr =
        'Scheduled #$currentId: $reminderTime, ${task.title}, ${studyNotification.taskInstance.id}';
    StudyNotifications.scheduledNotificationsDebug =
        '${StudyNotifications.scheduledNotificationsDebug}\n\n$debugStr';
    if (StudyNotifications.debug) {
      print(debugStr);
    }
    currentId++;
  }
  return currentId;
}

const notificationDetails =
    NotificationDetails(android: AndroidNotificationDetails('0', 'StudyU'));

Future<void> scheduleNotifications(BuildContext context) async {
  if (StudyNotifications.debug) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Schedule Notifications'),
      ),
    );
    print('Schedule Notifications');
  }
  // Notifications not supported on web
  if (kIsWeb) return;
  final appState = context.read<AppState>();
  final subject = appState.activeSubject!;
  final body = AppLocalizations.of(context)!.study_notification_body;
  context.read<AppState>().studyNotifications ??=
      await StudyNotifications.create(subject, context);
  final notificationsPlugin =
      appState.studyNotifications!.flutterLocalNotificationsPlugin;
  notificationsPlugin.cancelAll();

  StudyNotifications.scheduledNotificationsDebug =
      "Timestamp: ${DateTime.now()}\nSubject ID: ${subject.id}\n";
  final List<StudyNotification> studyNotificationList = [];

  for (int index = 0; index <= 7; index++) {
    final date = DateTime.now().add(Duration(days: index));
    final tasks = subject.scheduleFor(date);
    studyNotificationList.addAll(_buildNotificationList(subject, date, tasks));
  }
  var id = 0;
  for (final StudyNotification notification in studyNotificationList) {
    final currentId = await scheduleReminderForDate(
      notificationsPlugin,
      id,
      body,
      notification,
      notificationDetails,
    );
    id = currentId;
  }
}

List<StudyNotification> _buildNotificationList(
  StudySubject subject,
  DateTime date,
  List<TaskInstance> tasks,
) {
  final List<StudyNotification> taskNotifications = [];
  for (final TaskInstance taskInstance in tasks) {
    if (taskInstance.task.title == null || taskInstance.task.title!.isEmpty) {
      return [];
    }
    if (!subject.completedTaskInstanceForDay(
      taskInstance.task.id,
      taskInstance.completionPeriod,
      date,
    )) {
      taskNotifications.add(StudyNotification(taskInstance, date));
    } else {
      final String debugStr =
          'TaskInstance already completed: ${taskInstance.completionPeriod}, ${taskInstance.task.title}';
      StudyNotifications.scheduledNotificationsDebug =
          '${StudyNotifications.scheduledNotificationsDebug}\n\n$debugStr';
    }
  }
  return taskNotifications;
}

Future<void>? cancelNotifications(BuildContext context) async {
  if (kIsWeb) return Future.value(); // Notifications not supported on web
  final appState = context.read<AppState>();
  final notificationsPlugin =
      appState.studyNotifications?.flutterLocalNotificationsPlugin;

  await notificationsPlugin?.cancelAll();
  await FlutterLocalNotificationsPlugin().cancelAll();
  final list1 = await notificationsPlugin?.pendingNotificationRequests() ?? [];
  final list2 =
      await FlutterLocalNotificationsPlugin().pendingNotificationRequests();
  final listres = list1.isEmpty && list2.isEmpty;
  assert(listres);
  StudyNotifications.scheduledNotificationsDebug = 'cleared';

  if (StudyNotifications.debug) {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Notifications cancelled and pending notifications are empty: $listres',
          ),
        ),
      );
    }
    print('Notifications cancelled');
  }
  return Future.value();
}

class StudyNotification {
  StudyNotification(
    this.taskInstance,
    this.date,
  );

  final TaskInstance taskInstance;
  final DateTime date;
}
