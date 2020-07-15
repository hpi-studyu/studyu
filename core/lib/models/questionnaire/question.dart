import 'package:json_annotation/json_annotation.dart';

import 'questions/questions.dart';

typedef QuestionParser = Question Function(Map<String, dynamic> data);

abstract class Question {
  static Map<String, QuestionParser> questionTypes = {
    AnnotatedScaleQuestion.questionType: (json) => AnnotatedScaleQuestion.fromJson(json),
    BooleanQuestion.questionType: (json) => BooleanQuestion.fromJson(json),
    ChoiceQuestion.questionType: (json) => ChoiceQuestion.fromJson(json),
    VisualAnalogueQuestion.questionType: (json) => VisualAnalogueQuestion.fromJson(json),
  };
  static const String keyType = 'type';
  String type;

  String id;
  String prompt;
  @JsonKey(nullable: true)
  String rationale;

  Question(this.type);

  factory Question.fromJson(Map<String, dynamic> data) => questionTypes[data[keyType]](data);
  Map<String, dynamic> toJson();

  @override
  String toString() {
    return toJson().toString();
  }
}
