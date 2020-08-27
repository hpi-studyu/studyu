import 'package:json_annotation/json_annotation.dart';

import '../../questionnaire/question.dart';
import '../../questionnaire/questionnaire.dart';
import '../../questionnaire/questionnaire_state.dart';
import '../../results/result.dart';
import '../../tasks/schedule.dart';
import '../observation.dart';

part 'questionnaire_task.g.dart';

@JsonSerializable()
class QuestionnaireTask extends Observation {
  static const String taskType = 'questionnaire';

  Questionnaire questions;

  QuestionnaireTask() : super(taskType);

  QuestionnaireTask.designer()
      : this.questions = Questionnaire.designer(),
        super.designer(taskType);

  factory QuestionnaireTask.fromJson(Map<String, dynamic> json) => _$QuestionnaireTaskFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$QuestionnaireTaskToJson(this);

  @override
  Map<DateTime, T> extractPropertyResults<T>(String property, List<Result> sourceResults) {
    Question targetQuestion = questions.questions.firstWhere((q) => q.id == property, orElse: null);
    if (targetQuestion == null)
      throw new ArgumentError('Questionnaire \'${this.id}\' does not have a question with \'$property\'.');
    var typedResults = sourceResults.cast<Result<QuestionnaireState>>();
    return Map.fromEntries(typedResults.map((r) => new MapEntry(r.timeStamp, r.result.getAnswer<T>(property))));
  }

  @override
  Map<String, Type> getAvailableProperties() => {for (var q in questions.questions) q.id: q.getAnswerType()};

  @override
  String getHumanReadablePropertyName(String property) =>
      questions.questions.firstWhere((q) => q.id == property, orElse: null).prompt;
}
