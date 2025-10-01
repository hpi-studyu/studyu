import 'package:studyu_core/core.dart';

class ScheduleConverter {
  ScheduleConverter._();

  static Map<String, dynamic> exportSchedule(Schedule schedule) {
    return {
      'completionWindows': [
        for (final period in schedule.completionPeriods)
          {
            'start': period.unlockTime.toString(),
            'end': period.lockTime.toString(),
          },
      ],
      'reminders': [
        for (final reminder in schedule.reminders) reminder.toString(),
      ],
    };
  }

  static Schedule importSchedule(Map<String, dynamic>? data) {
    final schedule = Schedule();
    if (data == null) return schedule;
    final completionWindows = (data['completionWindows'] as List? ?? [])
        .cast<Map<String, dynamic>>();
    if (completionWindows.isNotEmpty) {
      schedule.completionPeriods = completionWindows
          .map(
            (window) => CompletionPeriod.noId(
              unlockTime: StudyUTimeOfDay.fromJson(window['start'] as String),
              lockTime: StudyUTimeOfDay.fromJson(window['end'] as String),
            ),
          )
          .toList();
    }
    schedule.reminders = (data['reminders'] as List? ?? [])
        .map((value) => StudyUTimeOfDay.fromJson(value as String))
        .toList();
    return schedule;
  }
}
