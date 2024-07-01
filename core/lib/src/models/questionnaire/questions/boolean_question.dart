import 'package:json_annotation/json_annotation.dart';

import 'package:studyu_core/src/models/questionnaire/answer.dart';
import 'package:studyu_core/src/models/questionnaire/question.dart';
import 'package:studyu_core/src/models/questionnaire/question_conditional.dart';

part 'boolean_question.g.dart';

@JsonSerializable()
class BooleanQuestion extends Question<bool> {
  static const String questionType = 'boolean';

  BooleanQuestion() : super(questionType);

  BooleanQuestion.withId() : super.withId(questionType);

  factory BooleanQuestion.fromJson(Map<String, dynamic> json) =>
      _$BooleanQuestionFromJson(json);
  @override
  Map<String, dynamic> toJson() => _$BooleanQuestionToJson(this);

  // ignore: avoid_positional_boolean_parameters
  Answer<bool> constructAnswer(bool response) =>
      Answer.forQuestion(this, response);
}
