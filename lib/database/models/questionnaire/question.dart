import 'package:collection/collection.dart';

import 'questions/boolean_question.dart';
import 'questions/choice_question.dart';

typedef QuestionParser = Question Function(Map<String, dynamic> data);

abstract class Question {
  static Map<String, QuestionParser> questionTypes = {
    BooleanQuestion.questionType: (data) => BooleanQuestion.fromJson(data),
    ChoiceQuestion.questionType: (data) => ChoiceQuestion.fromJson(data)
  };
  static const String keyType = 'type';
  String get type => null;

  String id;
  String prompt;

  Question();

  factory Question.fromJson(Map<String, dynamic> data) {
    return questionTypes[data[keyType]](data);
  }

  Map<String, dynamic> toJsonData();
  Map<String, dynamic> toJson() => mergeMaps<String, dynamic>({ keyType: type }, toJsonData());

  @override
  String toString() {
    return toJson().toString();
  }
}
