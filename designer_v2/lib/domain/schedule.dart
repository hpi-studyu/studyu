import 'package:flutter/material.dart';
import 'package:studyu_core/core.dart';
import 'package:studyu_designer_v2/features/forms/form_data.dart';

extension StudyUTimeOfDayX on StudyUTimeOfDay {
  bool equals({required int hour, required int minute}) {
    if (hour != this.hour) return false;
    if (minute != this.minute) return false;
    return true;
  }

  bool equalsTo(StudyUTimeOfDay other) {
    return hour == other.hour && minute == other.minute;
  }

  TimeOfDay toTimeOfDay() {
    return TimeOfDay(hour: hour, minute: minute);
  }

  StudyUTimeOfDay fromTimeOfDay(TimeOfDay time) {
    return StudyUTimeOfDay(hour: time.hour, minute: time.minute);
  }
}

extension TimeOfDayX on TimeOfDay {
  StudyUTimeOfDay toStudyUTimeOfDay() {
    return StudyUTimeOfDay(hour: hour, minute: minute);
  }
}

extension ScheduleX on Schedule {
  static final unrestrictedTime = [
    StudyUTimeOfDay(hour: 0, minute: 0),
    StudyUTimeOfDay(hour: 23, minute: 59),
  ];

  bool get isTimeRestricted => !(completionPeriods.isEmpty ||
      (completionPeriods.length == 1 &&
          completionPeriods[0].unlockTime.equalsTo(unrestrictedTime[0]) &&
          completionPeriods[0].lockTime.equalsTo(unrestrictedTime[1])));

  bool get hasReminder => reminders.isNotEmpty;

  StudyUTimeOfDay? get reminderTime {
    if (!hasReminder) {
      return null;
    }
    return reminders[0];
  }

  StudyUTimeOfDay? get restrictedTimeStart {
    if (!isTimeRestricted) {
      return null;
    }
    return completionPeriods[0].unlockTime;
  }

  StudyUTimeOfDay? get restrictedTimeEnd {
    if (!isTimeRestricted) {
      return null;
    }
    return completionPeriods[0].lockTime;
  }
}

abstract class IFormDataWithSchedule implements IFormData {
  IFormDataWithSchedule(
      {required this.isTimeLocked,
        this.timeLockStart,
        this.timeLockEnd,
        required this.hasReminder,
        this.reminderTime});

  final bool isTimeLocked;
  final StudyUTimeOfDay? timeLockStart;
  final StudyUTimeOfDay? timeLockEnd;
  final bool hasReminder;
  final StudyUTimeOfDay? reminderTime;

  Schedule toSchedule() {
    final schedule = Schedule();
    schedule.reminders =
    (!hasReminder || reminderTime == null) ? [] : [reminderTime!];
    schedule.completionPeriods =
    (!isTimeLocked || (timeLockStart == null && timeLockEnd == null))
        ? [
      CompletionPeriod(
        // default unrestricted period
          unlockTime: ScheduleX.unrestrictedTime[0],
          lockTime: ScheduleX.unrestrictedTime[1])
    ]
        : [
      CompletionPeriod(
        // user-defined period
          unlockTime: timeLockStart ?? ScheduleX.unrestrictedTime[0],
          lockTime: timeLockEnd ?? ScheduleX.unrestrictedTime[1])
    ];
    return schedule;
  }
}
