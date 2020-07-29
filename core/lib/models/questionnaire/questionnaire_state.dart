import 'answer.dart';

class QuestionnaireState {
  Map<String, Answer> answers;

  QuestionnaireState() : answers = {};

  QuestionnaireState.fromJson(List<Map<String, dynamic>> json)
      : answers = Map.fromIterable(json.map<Answer>(Answer.fromJson), key: (answer) => answer.question);
  List<Map<String, dynamic>> toJson() => answers.values.map((answer) => answer.toJson()).toList();

  bool hasAnswer<T>(String question) {
    return answers[question] is Answer<T>;
  }

  T getAnswer<T>(String question) {
    final dynamic answer = answers[question];
    if (answer is Answer<T>) {
      return answer.response;
    } else {
      throw TypeError();
    }
  }
}
