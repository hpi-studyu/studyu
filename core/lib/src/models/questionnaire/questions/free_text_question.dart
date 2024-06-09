import 'package:json_annotation/json_annotation.dart';

import 'package:studyu_core/src/models/questionnaire/answer.dart';
import 'package:studyu_core/src/models/questionnaire/question.dart';
import 'package:studyu_core/src/models/questionnaire/question_conditional.dart';

part 'free_text_question.g.dart';

@JsonSerializable()
class FreeTextQuestion extends Question<String> {
  static const String questionType = 'freeText';

  @JsonKey(name: 'lengthRange')
  List<int> lengthRange;

  @JsonKey(name: 'textType')
  FreeTextQuestionType textType;

  @JsonKey(name: 'customTypeExpression')
  String? customTypeExpression;

  FreeTextQuestion(
      {required this.textType,
      required this.lengthRange,
      this.customTypeExpression})
      : super(questionType);

  FreeTextQuestion.withId(
      {required this.textType,
      required this.lengthRange,
      this.customTypeExpression})
      : super.withId(questionType);

  factory FreeTextQuestion.fromJson(Map<String, dynamic> json) =>
      _$FreeTextQuestionFromJson(json);
  @override
  Map<String, dynamic> toJson() => _$FreeTextQuestionToJson(this);

  Answer<String> constructAnswer(String response) =>
      Answer.forQuestion(this, response);
}

enum FreeTextQuestionType {
  any,
  alphanumeric,
  numeric,
  custom;

  String toJson() => name;
  static FreeTextQuestionType fromJson(String json) => values.byName(json);
}

const alphanumericPattern = r'^[a-zA-Z0-9]*$';
