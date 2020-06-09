import 'answer.dart';

class QuestionnaireState {
  Map<String, Answer> answers;

  QuestionnaireState() : answers = {};

  QuestionnaireState.fromJson(List<Map<String, dynamic>> json) :
      answers = Map.fromIterable(json.map(Answer.parseJson), key: (answer) => answer.id);
  List<Map<String, dynamic>> toJson() => answers.values.map((answer) => answer.toJson()).toList();

  T getAnswer<T>(String question) {
    dynamic answer = answers[question];
    if (answer is Answer<T>) {
      return answer.response;
    } else {
      throw TypeError();
    }
  }
}
