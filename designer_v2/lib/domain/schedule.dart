import 'package:flutter/material.dart';
import 'package:studyu_core/core.dart';
import 'package:studyu_designer_v2/utils/time_of_day.dart';

extension StudyUTimeOfDayX on StudyUTimeOfDay {
  bool equals({required int hour, required int minute}) {
    if (hour != this.hour) return false;
    if (minute != this.minute) return false;
    return true;
  }

  bool equalsTo(StudyUTimeOfDay other) {
    return hour == other.hour && minute == other.minute;
  }

  Time toTime() {
    return Time(hour: hour, minute: minute);
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

// todo make this compatible with multiple completionPeriods
extension ScheduleX on Schedule {
  String get instanceId => completionPeriods[0].id;

  static final unrestrictedTime = [
    StudyUTimeOfDay(),
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
