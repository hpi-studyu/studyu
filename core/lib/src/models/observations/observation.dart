import 'package:studyu_core/src/models/observations/tasks/tasks.dart';
import 'package:studyu_core/src/models/observations/tasks/unknown_task.dart';
import 'package:studyu_core/src/models/tasks/task.dart';

typedef ObservationTaskParser = Observation Function(Map<String, dynamic> data);

abstract class Observation extends Task {
  Observation(super.type);

  Observation.withId(super.type) : super.withId();

  bool get isSupported;

  factory Observation.fromJson(Map<String, dynamic> data) => switch (data[Task.keyType]) {
        QuestionnaireTask.taskType => QuestionnaireTask.fromJson(data),
        _ => UnknownTask(),
      };
}
