import 'package:studyu_core/src/models/interventions/tasks/checkmark_task.dart';
import 'package:studyu_core/src/models/tasks/task.dart';

typedef InterventionTaskParser = InterventionTask Function(Map<String, dynamic> data);

abstract class InterventionTask extends Task {
  static Map<String, InterventionTaskParser> taskTypes = {
    CheckmarkTask.taskType: (json) => CheckmarkTask.fromJson(json),
  };

  InterventionTask(super.type);

  InterventionTask.withId(super.type) : super.withId();

  factory InterventionTask.fromJson(Map<String, dynamic> data) => taskTypes[data[Task.keyType]]!(data);
}
