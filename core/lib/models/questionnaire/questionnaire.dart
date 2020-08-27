import 'question.dart';

// TODO: We might want to make this @JsonSerializable() as well, but it does not support list types
class Questionnaire {
  List<Question> questions;

  Questionnaire();

  Questionnaire.designer() : questions = [];

  Questionnaire.fromJson(List<dynamic> data) {
    questions = data.map((entry) => Question.fromJson(entry)).toList();
  }

  List<dynamic> toJson() => questions.map((question) => question.toJson()).toList();
}
