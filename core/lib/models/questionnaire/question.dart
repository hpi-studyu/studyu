import 'package:json_annotation/json_annotation.dart';
import 'package:studyou_core/models/models.dart';
import 'package:studyou_core/models/questionnaire/question_conditional.dart';

import 'questions/questions.dart';

typedef QuestionParser = Question Function(Map<String, dynamic> data);

abstract class Question<V> {
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

  static const String keyConditional = 'conditional';
  @JsonKey(ignore: true)
  QuestionConditional<V> conditional;

  Question(this.type);

  factory Question.fromJson(Map<String, dynamic> data) {
    var question = questionTypes[data[keyType]](data);
    question.conditional = data[keyConditional] != null ? QuestionConditional.fromJson(data[keyConditional]) : null;
    return question;
  }
  Map<String, dynamic> serializeToJson();
  Map<String, dynamic> toJson() {
    var result = serializeToJson();
    if (conditional != null) result[keyConditional] = conditional.toJson();
    return result;
  }

  bool shouldBeShown(QuestionnaireState state) {
    if (conditional == null) return true;
    return conditional.condition.evaluate(state) != false;
  }

  Answer<V> getDefaultAnswer() {
    return conditional?.defaultValue;
  }

  @override
  String toString() {
    return toJson().toString();
  }
}
