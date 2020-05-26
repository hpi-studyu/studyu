import 'package:flutter/cupertino.dart';

import 'multiple_choice_answer.dart';

class Answer {

  static const String answerType = null;
  String get type => answerType;

  int id;
  DateTime timestamp;
  int questionId;

  Answer(this.id, this.timestamp, this.questionId);

  Answer.fromJsonScaffold(Map<String, dynamic> data) {
    id = data['id'];
    timestamp = data['timestamp'];
    questionId = data['questionId'];
  }

  factory Answer.fromJson(Map<String, dynamic> data) {
    if (!data.containsKey('type')) throw 'Missing condition type!';
    switch (data['type']) {
      case MultipleChoiceAnswer.answerType:
        return MultipleChoiceAnswer.fromJson(data);
      default:
        throw 'Unknown condition type!';
    }
  }

  Map<String, dynamic> toJson() => {
    'answer_id': id,
    'type': type,
    'timestamp': timestamp,
    'questionId': questionId
  };

  @override
  String toString() {
    return toJson().toString();
  }

}

class BooleanAnswer extends Answer {
  bool answerValue;

  BooleanAnswer(int id, DateTime timestamp, int questionId, {@required this.answerValue}) : super(id, timestamp, questionId);

}