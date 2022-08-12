import 'package:studyu_core/core.dart';
import 'package:studyu_designer_v2/domain/task.dart';
import 'package:studyu_designer_v2/features/forms/form_data.dart';
import 'package:studyu_designer_v2/utils/extensions.dart';
import 'package:uuid/uuid.dart';

class InterventionTaskFormData implements IFormData {
  InterventionTaskFormData({
    required this.taskId,
    required this.taskTitle,
    this.taskDescription,
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
    );
  }

  CheckmarkTask toTask() {
    final task = CheckmarkTask();
    task.id = taskId;
    task.title = taskTitle;
    task.header = taskDescription; // TODO figure out header vs footer here
    return task;
  }

  @override
  InterventionTaskFormData copy() {
    return InterventionTaskFormData(
      taskId: const Uuid().v4(), // always regenerate id
      taskTitle: taskTitle.withDuplicateLabel(),
      taskDescription: taskDescription,
    );
  }
}
