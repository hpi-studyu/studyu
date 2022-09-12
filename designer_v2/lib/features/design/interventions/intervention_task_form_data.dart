import 'package:studyu_core/core.dart';
import 'package:studyu_designer_v2/domain/schedule.dart';
import 'package:studyu_designer_v2/domain/task.dart';
import 'package:studyu_designer_v2/features/design/shared/schedule/schedule_form_data.dart';
import 'package:studyu_designer_v2/utils/extensions.dart';
import 'package:uuid/uuid.dart';

class InterventionTaskFormData extends IFormDataWithSchedule {
  static String kDefaultTitle = "Unnamed task";

  InterventionTaskFormData({
    required this.taskId,
    required this.taskTitle,
    this.taskDescription,
    required super.isTimeLocked,
    super.timeLockStart,
    super.timeLockEnd,
    required super.hasReminder,
    super.reminderTime,
  });

  final TaskID taskId;
  final String taskTitle;
  final String? taskDescription;

  @override
  String get id => taskId;

  factory InterventionTaskFormData.fromDomainModel(CheckmarkTask task) {
    return InterventionTaskFormData(
      taskId: task.id,
      taskTitle: task.title ?? '',
      taskDescription: task.header, // TODO figure out header vs footer here
      isTimeLocked: task.schedule.isTimeRestricted,
      timeLockStart: task.schedule.restrictedTimeStart,
      timeLockEnd: task.schedule.restrictedTimeEnd,
      hasReminder: task.schedule.hasReminder,
      reminderTime: task.schedule.reminderTime,
    );
  }

  CheckmarkTask toTask() {
    final task = CheckmarkTask();
    task.id = taskId;
    task.title = taskTitle;
    task.header = taskDescription; // TODO figure out header vs footer here
    task.schedule = toSchedule();
    return task;
  }

  @override
  InterventionTaskFormData copy() {
    return InterventionTaskFormData(
      taskId: const Uuid().v4(), // always regenerate id
      taskTitle: taskTitle.withDuplicateLabel(),
      taskDescription: taskDescription,
      isTimeLocked: isTimeLocked,
      timeLockStart: timeLockStart,
      timeLockEnd: timeLockEnd,
      hasReminder: hasReminder,
      reminderTime: reminderTime,
    );
  }
}
