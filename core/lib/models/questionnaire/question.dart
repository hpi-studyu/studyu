import 'package:studyou_core/models/models.dart';
import 'package:studyou_core/models/questionnaire/question_conditional.dart';
import 'package:uuid/uuid.dart';

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
  String rationale;

  static const String keyConditional = 'conditional';
  QuestionConditional<V> conditional;

  Question(this.type);

  Question.designer(this.type) : id = Uuid().v4();

  factory Question.fromJson(Map<String, dynamic> data) {
    return questionTypes[data[keyType]](data) as Question<V>;
  }

  Map<String, dynamic> toJson();

  bool shouldBeShown(QuestionnaireState state) {
    if (conditional == null) return true;
    return conditional.condition.evaluate(state) != false;
  }

  Answer<V> getDefaultAnswer() {
    if (conditional == null) return null;
    return Answer.forQuestion(this, conditional.defaultValue);
  }

  Type getAnswerType() => V;

  @override
  String toString() {
    return toJson().toString();
  }
}
