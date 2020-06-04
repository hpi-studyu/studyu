typedef QuestionParser = Question Function(Map<String, dynamic> data);

class Question {
  static Map<String, QuestionParser> questionTypes;
  static String registerQuestionType(String key, QuestionParser f) {
    questionTypes[key] = f;
    return key;
  }

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
    return questionTypes[data.remove(keyType)](data);
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

  Answer.fromJsonScaffold(Map<String, dynamic> data) {
    question = data[keyQuestion];
    timestamp = data[keyTimestamp];
    response = data[keyResponse] as V;
  }

  static Answer fromJson(Map<String, dynamic> data) {
    dynamic value = data[keyResponse];
    switch (value.runtimeType) {
      case bool:
        return Answer<bool>.fromJsonScaffold(data);
      case int:
        return Answer<int>.fromJsonScaffold(data);
      case String:
        return Answer<String>.fromJsonScaffold(data);
      default:
        if (value is List<String>) {
          return Answer<List<String>>.fromJsonScaffold(data);
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
