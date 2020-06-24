import '../tasks/task.dart';
import 'tasks/questionnaire_task.dart';

typedef ObservationTaskParser = ObservationTask Function(Map<String, dynamic> data);

abstract class ObservationTask extends Task {
  static Map<String, ObservationTaskParser> taskTypes = {
    QuestionnaireTask.taskType: (json) => QuestionnaireTask.fromJson(json),
  };

  ObservationTask();

  factory ObservationTask.fromJson(Map<String, dynamic> data) => taskTypes[data[Task.keyType]](data);
}
