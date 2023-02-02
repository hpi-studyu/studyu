import 'package:studyu_core/src/models/observations/tasks/tasks.dart';
import 'package:studyu_core/src/models/tasks/task.dart';

typedef ObservationTaskParser = Observation Function(Map<String, dynamic> data);

abstract class Observation extends Task {
  static Map<String, ObservationTaskParser> taskTypes = {
    QuestionnaireTask.taskType: (json) => QuestionnaireTask.fromJson(json),
  };

  Observation(super.type);

  Observation.withId(super.type) : super.withId();

  factory Observation.fromJson(Map<String, dynamic> data) => taskTypes[data[Task.keyType]]!(data);
}
