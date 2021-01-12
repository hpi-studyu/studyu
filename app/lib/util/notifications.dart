import 'package:flutter/widgets.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:provider/provider.dart';
import 'package:studyou_core/models/models.dart' as models;
import 'package:studyou_core/util/extensions.dart';
import 'package:timezone/timezone.dart' as tz;

import '../models/app_state.dart';

extension Reminders on FlutterLocalNotificationsPlugin {
  Future<void> scheduleReminderForDate(
      int initialId, models.Task task, DateTime date, NotificationDetails notificationDetails) async {
    var id = initialId;
    for (final taskSchedule in task.schedule) {
      switch (taskSchedule.type) {
        case models.FixedSchedule.scheduleType:
          final models.FixedSchedule fixedSchedule = taskSchedule;
          if (date.isSameDate(DateTime.now()) &&
              !models.Time(hour: date.hour, minute: date.minute).earlierThan(fixedSchedule.time)) {
            break;
          }

          final reminderTime = tz.TZDateTime(
              tz.local, date.year, date.month, date.day, fixedSchedule.time.hour, fixedSchedule.time.minute);
          // TODO add body
          zonedSchedule(id, task.title, '', reminderTime, notificationDetails,
              payload: task.id,
              uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.wallClockTime,
              androidAllowWhileIdle: true);
      }
      id++;
    }
  }
}

Future<void> scheduleStudyNotifications(BuildContext context) async {
  final appState = context.read<AppState>();
  final androidPlatformChannelSpecifics =
      AndroidNotificationDetails('0', 'StudyU main', 'The main StudyU notification channel.');
  final iOSPlatformChannelSpecifics = IOSNotificationDetails();
  final platformChannelSpecifics =
      NotificationDetails(android: androidPlatformChannelSpecifics, iOS: iOSPlatformChannelSpecifics);

  final study = appState.activeStudy;

  if (study != null) {
    final interventionTaskLists =
        study.interventionSet.interventions?.map((intervention) => intervention.tasks)?.toList() ?? [];
    var interventionTasks = [];
    if (interventionTaskLists.isNotEmpty) {
      interventionTasks = interventionTaskLists.reduce((firstList, secondList) => [...firstList, ...secondList]) ?? [];
    }
    final tasks = [
      ...study.observations,
      ...interventionTasks,
    ];
    if (tasks.isEmpty) return;
    var id = 0;
    for (final index in List.generate(3, (index) => index)) {
      final date = DateTime.now().add(Duration(days: index));
      for (final observation in study.observations) {
        (await appState.notificationsPlugin)
            .scheduleReminderForDate(id - observation.schedule.length, observation, date, platformChannelSpecifics);
        id += observation.schedule.length;
      }
      for (final intervention in study.interventionSet?.interventions ?? <models.Intervention>[]) {
        if (intervention.id == null || intervention.id != study.getInterventionForDate(date)?.id) {
          if (intervention.tasks.isNotEmpty) {
            id += intervention.tasks.map((task) => task.schedule.length).reduce((a, b) => a + b);
          }
          continue;
        }
        for (final task in intervention.tasks) {
          (await appState.notificationsPlugin).scheduleReminderForDate(id, task, date, platformChannelSpecifics);
          id += task.schedule.length;
        }
      }
    }
  }
}
