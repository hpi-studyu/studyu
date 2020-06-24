import 'questions/annotated_scale_question.dart';
import 'questions/boolean_question.dart';
import 'questions/choice_question.dart';
import 'questions/visual_analogue_question.dart';

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

  Question();

  factory Question.fromJson(Map<String, dynamic> data) => questionTypes[data[keyType]](data);
  Map<String, dynamic> toJson();

  @override
  String toString() {
    return toJson().toString();
  }
}
