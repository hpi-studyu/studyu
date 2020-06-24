import '../tasks/task.dart';
import 'tasks/checkmark_task.dart';

abstract class InterventionTask extends Task {
  static Map<String, TaskParser> taskTypes = {
    CheckmarkTask.taskType: (json) => CheckmarkTask.fromJson(json),
  };

  InterventionTask();

  factory InterventionTask.fromJson(Map<String, dynamic> data) => taskTypes[data[Task.keyType]](data);
}
