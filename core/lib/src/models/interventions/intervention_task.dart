import 'package:studyu_core/src/models/interventions/tasks/checkmark_task.dart';
import 'package:studyu_core/src/models/interventions/tasks/unknown_intervention_task.dart';
import 'package:studyu_core/src/models/tasks/task.dart';

typedef InterventionTaskParser = InterventionTask Function(Map<String, dynamic> data);

abstract class InterventionTask extends Task {
  InterventionTask(super.type);

  InterventionTask.withId(super.type) : super.withId();

  bool get isSupported => true;

  factory InterventionTask.fromJson(Map<String, dynamic> data) => switch (data[Task.keyType]) {
        CheckmarkTask.taskType => CheckmarkTask.fromJson(data),
        _ => UnknownInterventionTask(),
      };
}
