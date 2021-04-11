import 'question.dart';

// TODO: We might want to make this @JsonSerializable() as well, but it does not support list types
class Questionnaire {
  List<Question> questions;

  Questionnaire();

  Questionnaire.designerDefault() : questions = [];

  factory Questionnaire.fromJson(List<dynamic> data) =>
      Questionnaire()..questions = data.map((entry) => Question.fromJson(entry as Map<String, dynamic>)).toList();

  List<dynamic> toJson() => questions.map((question) => question.toJson()).toList();
}
