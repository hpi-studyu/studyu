import 'package:collection/collection.dart' show IterableExtension;
import 'package:json_annotation/json_annotation.dart';

import '../../models.dart';
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

  Questionnaire questions = Questionnaire();

  QuestionnaireTask() : super(taskType);

  QuestionnaireTask.withId() : super.withId(taskType);

  factory QuestionnaireTask.fromJson(Map<String, dynamic> json) => _$QuestionnaireTaskFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$QuestionnaireTaskToJson(this);

  @override
  Map<DateTime, T> extractPropertyResults<T>(String property, List<SubjectProgress> sourceResults) {
    final Question? targetQuestion = questions.questions.firstWhereOrNull((q) => q.id == property);
    if (targetQuestion == null) {
      throw ArgumentError("Questionnaire '$id' does not have a question with '$property'.");
    }
    return Map.fromEntries(sourceResults
        .map((e) => MapEntry(e.completedAt!, (e.result as Result<QuestionnaireState>).result.getAnswer<T>(property))));
  }

  @override
  Map<String, Type> getAvailableProperties() => {for (var q in questions.questions) q.id: q.getAnswerType()};

  @override
  String? getHumanReadablePropertyName(String property) =>
      questions.questions.firstWhereOrNull((q) => q.id == property)!.prompt;
}
