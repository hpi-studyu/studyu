import 'package:json_annotation/json_annotation.dart';

import '../answer.dart';
import '../question.dart';

part 'boolean_question.g.dart';

@JsonSerializable()
class BooleanQuestion extends Question {
  static const String questionType = 'boolean';
  @override
  String get type => questionType;

  BooleanQuestion();

  factory BooleanQuestion.fromJson(Map<String, dynamic> json) => _$BooleanQuestionFromJson(json);
  @override
  Map<String, dynamic> toJsonData() => _$BooleanQuestionToJson(this);

  // ignore: avoid_positional_boolean_parameters
  Answer<bool> constructAnswer(bool response) => Answer.forQuestion(this, response);
}
