import 'questions/boolean_question.dart';
import 'questions/choice_question.dart';

typedef QuestionParser = Question Function(Map<String, dynamic> data);

abstract class Question {
  static Map<String, QuestionParser> questionTypes = {
    BooleanQuestion.questionType: (data) => BooleanQuestion.fromJson(data),
    ChoiceQuestion.questionType: (data) => ChoiceQuestion.fromJson(data)
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
