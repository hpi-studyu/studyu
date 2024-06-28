import 'package:studyu_core/src/models/questionnaire/answer.dart';

class QuestionnaireState {
  Map<String, Answer> answers;

  QuestionnaireState() : answers = {};

  QuestionnaireState.fromJson(List<Map<String, dynamic>> json)
      : answers = Map<String, Answer>.fromIterable(
          json.map<Answer>(Answer.fromJson),
          key: (answer) => (answer as Answer).question,
        );
  List<Map<String, dynamic>> toJson() =>
      answers.values.map((answer) => answer.toJson()).toList();

  bool hasAnswer<T>(String question) {
    return answers[question] is Answer<T>;
  }

  T getAnswer<T>(String question) {
    final dynamic answer = answers[question];
    if (answer is Answer<T>) {
      return answer.response;
    } else {
      throw ArgumentError(
        "'Answer<$T>' requested but found '${answer.runtimeType}'.",
      );
    }
  }
}
