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

  static const String keyID = 'id';
  String id;

  static const String keyPrompt = 'prompt';
  String prompt;

  Question.fromJson(Map<String, dynamic> data) {
    id = data[keyID];
    prompt = data[keyPrompt];
  }

  factory Question.parseJson(Map<String, dynamic> data) {
    return questionTypes[data[keyType]](data);
  }

  Map<String, dynamic> toJson() => {
    keyType: type,
    keyID: id,
    keyPrompt: prompt
  };

  @override
  String toString() {
    return toJson().toString();
  }
}

class Answer<V> {
  static const String answerType = null;
  String get type => answerType;

  static const String keyQuestion = 'question';
  String question;

  static const String keyTimestamp = 'timestamp';
  DateTime timestamp;

  static const String keyResponse = 'response';
  V response;

  Answer(this.question, this.timestamp, this.response);

  Answer.forQuestion(Question question, this.response) : question = question.id, timestamp = DateTime.now();

  Answer.fromJson(Map<String, dynamic> data) {
    question = data[keyQuestion];
    timestamp = data[keyTimestamp];
    response = data[keyResponse] as V;
  }

  static Answer parseJson(Map<String, dynamic> data) {
    dynamic value = data[keyResponse];
    switch (value.runtimeType) {
      case bool:
        return Answer<bool>.fromJson(data);
      case int:
        return Answer<int>.fromJson(data);
      case String:
        return Answer<String>.fromJson(data);
      default:
        if (value is List<String>) {
          return Answer<List<String>>.fromJson(data);
        } else {
          throw ArgumentError('Unknown answer type: ${value.runtimeType}');
        }
    }
  }

  Map<String, dynamic> toJson() => {
    keyQuestion: question,
    keyTimestamp: timestamp,
    keyResponse: response
  };

  @override
  String toString() {
    return toJson().toString();
  }
}
