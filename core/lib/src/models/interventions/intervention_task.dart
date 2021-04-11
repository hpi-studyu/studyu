import '../tasks/task.dart';
import 'tasks/checkmark_task.dart';

typedef InterventionTaskParser = InterventionTask Function(Map<String, dynamic> data);

abstract class InterventionTask extends Task {
  static Map<String, InterventionTaskParser> taskTypes = {
    CheckmarkTask.taskType: (json) => CheckmarkTask.fromJson(json),
  };

  InterventionTask(String type) : super(type);

  InterventionTask.designer(String type) : super.designer(type);

  factory InterventionTask.fromJson(Map<String, dynamic> data) => taskTypes[data[Task.keyType]](data);
}
