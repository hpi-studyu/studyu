import 'package:json_annotation/json_annotation.dart';

import '../../questionnaire/questionnaire.dart';
import '../../tasks/schedule.dart';
import '../observation.dart';

part 'questionnaire_task.g.dart';

@JsonSerializable()
class QuestionnaireTask extends Observation {
  static const String taskType = 'questionnaire';

  Questionnaire questions;

  QuestionnaireTask() : super(taskType);

  factory QuestionnaireTask.fromJson(Map<String, dynamic> json) => _$QuestionnaireTaskFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$QuestionnaireTaskToJson(this);
}
