import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:studyou_core/models/models.dart' as models;

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
                ..add(Duration(days: add));
          // TODO add body
          schedule(id, task.title, '', reminderTime, notificationDetails, payload: task.id);
      }
    }
  }
}
