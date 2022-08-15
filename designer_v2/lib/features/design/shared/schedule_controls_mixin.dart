import 'package:flutter/material.dart';
import 'package:reactive_forms/reactive_forms.dart';
import 'package:studyu_designer_v2/domain/schedule.dart';

mixin WithScheduleControls {
  final FormControl<bool> isTimeRestrictedControl =
      FormControl(validators: [Validators.required], value: false);
  final FormControl<TimeOfDay> restrictedTimeStartControl =
      FormControl(value: const TimeOfDay(hour: 0, minute: 0));
  final FormControl<TimeOfDay> restrictedTimeEndControl =
      FormControl(value: const TimeOfDay(hour: 23, minute: 59));

  final FormControl<bool> hasReminderControl =
      FormControl(validators: [Validators.required], value: false);
  final FormControl<TimeOfDay> reminderTimeControl = FormControl();

  bool get hasReminder => hasReminderControl.value!;
  bool get isTimeRestricted => isTimeRestrictedControl.value!;

  List<TimeOfDay>? get timeRestriction => (isTimeRestricted &&
          restrictedTimeStartControl.value != null &&
          restrictedTimeEndControl.value != null)
      ? [restrictedTimeStartControl.value!, restrictedTimeEndControl.value!]
      : null;

  late final scheduleFormControls = {
    'isTimeRestricted': isTimeRestrictedControl,
    'restrictedTimeStart': restrictedTimeStartControl,
    'restrictedTimeEnd': restrictedTimeEndControl,
    'hasReminder': hasReminderControl,
    'reminderTime': reminderTimeControl,
  };

  void setScheduleControlsFrom(IFormDataWithSchedule data) {
    isTimeRestrictedControl.value = data.isTimeLocked;
    restrictedTimeStartControl.value = data.timeLockStart?.toTimeOfDay();
    restrictedTimeEndControl.value = data.timeLockEnd?.toTimeOfDay();
    hasReminderControl.value = data.hasReminder;
    reminderTimeControl.value = data.reminderTime?.toTimeOfDay();
  }
}
