import '../tasks/task.dart';
import 'tasks/tasks.dart';

typedef ObservationTaskParser = Observation Function(Map<String, dynamic> data);

abstract class Observation extends Task {
  static Map<String, ObservationTaskParser> taskTypes = {
    QuestionnaireTask.taskType: (json) => QuestionnaireTask.fromJson(json),
  };

  Observation(String type) : super(type);

  factory Observation.fromJson(Map<String, dynamic> data) => taskTypes[data[Task.keyType]](data);
}
