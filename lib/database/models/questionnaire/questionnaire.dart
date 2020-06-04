import 'questions/question.dart';

class Questionnaire {
  List<Question> questions;

  Questionnaire();

  Questionnaire.fromJson(List<dynamic> data) {
    questions = data.map((entry) => Question.parseJson(entry)).toList();
  }

  List<dynamic> toJson() => questions.map((question) => question.toJson()).toList();
}

class QuestionnaireState {
  Map<String, Answer> answers = {};

  T getAnswer<T>(String question) {
    dynamic answer = answers[question];
    if (answer is Answer<T>) {
      return answer.response;
    } else {
      throw TypeError();
    }
  }

}
