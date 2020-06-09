import '../question.dart';

class BooleanQuestion extends Question {
  static const String questionType = 'boolean';
  @override
  String get type => questionType;

  BooleanQuestion.fromJson(Map<String, dynamic> data) : super.fromJson(data);

  @override
  Map<String, dynamic> toJson() => super.toJson();

  Answer<bool> constructAnswer(bool response) => Answer.forQuestion(this, response);
}
