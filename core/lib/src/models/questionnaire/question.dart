import 'package:uuid/uuid.dart';

import 'answer.dart';
import 'question_conditional.dart';
import 'questionnaire_state.dart';
import 'questions/questions.dart';

typedef QuestionParser = Question Function(Map<String, dynamic> data);

abstract class Question<V> {
  static Map<String, QuestionParser> questionTypes = {
    BooleanQuestion.questionType: (json) => BooleanQuestion.fromJson(json),
    ChoiceQuestion.questionType: (json) => ChoiceQuestion.fromJson(json),
    ScaleQuestion.questionType: (json) => ScaleQuestion.fromJson(json),
    AnnotatedScaleQuestion.questionType: (json) => AnnotatedScaleQuestion.fromJson(json),
    VisualAnalogueQuestion.questionType: (json) => VisualAnalogueQuestion.fromJson(json),
  };
  static const String keyType = 'type';
  String type;

  late String id;
  String? prompt;
  String? rationale;

  static const String keyConditional = 'conditional';
  QuestionConditional<V>? conditional;

  Question(this.type);

  Question.withId(this.type) : id = const Uuid().v4();

  factory Question.fromJson(Map<String, dynamic> data) {
    return questionTypes[data[keyType]]!(data) as Question<V>;
  }

  Map<String, dynamic> toJson();

  bool shouldBeShown(QuestionnaireState state) {
    if (conditional == null) return true;
    return conditional!.condition.evaluate(state) != false;
  }

  Answer<V>? getDefaultAnswer() {
    if (conditional == null || conditional!.defaultValue == null) return null;
    return Answer.forQuestion(this, conditional!.defaultValue as V);
  }

  Type getAnswerType() => V;

  @override
  String toString() {
    return toJson().toString();
  }
}
