import 'question.dart';

class BooleanQuestion extends Question {
  static String questionType = Question.registerQuestionType('boolean', (data) => BooleanQuestion.fromJson(data));
  @override
  String get type => questionType;

  BooleanQuestion.fromJson(Map<String, dynamic> data) : super.fromJson(data);

  @override
  Map<String, dynamic> toJson() => super.toJson();
}
