import 'package:studyu_core/core.dart';
import 'package:studyu_designer_v2/domain/schedule.dart';
import 'package:studyu_designer_v2/features/forms/form_data.dart';

abstract class IFormDataWithSchedule implements IFormData {
  IFormDataWithSchedule({
    required this.instanceId,
    required this.isTimeLocked,
    this.timeLockStart,
    this.timeLockEnd,
    required this.hasReminder,
    this.reminderTime,
  });

  final String instanceId;
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
                  id: instanceId,
                  // default unrestricted period
                  unlockTime: ScheduleX.unrestrictedTime[0],
                  lockTime: ScheduleX.unrestrictedTime[1],
                ),
              ]
            : [
                CompletionPeriod(
                  id: instanceId,
                  // user-defined period
                  unlockTime: timeLockStart ?? ScheduleX.unrestrictedTime[0],
                  lockTime: timeLockEnd ?? ScheduleX.unrestrictedTime[1],
                ),
              ];
    return schedule;
  }
}
