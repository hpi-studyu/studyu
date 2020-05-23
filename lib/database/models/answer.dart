import 'dart:collection';

import 'package:flutter/cupertino.dart';
import 'question.dart';

@immutable
abstract class Answer {
  final String id;
  final DateTime timestamp;
  final Question question;

  const Answer(this.id, this.timestamp, this.question);

  bool matches(Answer answer);
}

class BooleanAnswer extends Answer {
  final bool answerValue;

  BooleanAnswer(String id, DateTime timestamp, Question question, {@required this.answerValue}) : super(id, timestamp, question);

  @override
  bool matches(Answer answer) {
    return answer is BooleanAnswer && answer.answerValue == answerValue;
  }

}

class MultipleChoiceAnswer extends Answer {
  final HashSet<String> choices;

  MultipleChoiceAnswer(String id, DateTime timestamp, Question question, this.choices) : super(id, timestamp, question);

  @override
  bool matches(Answer answer) {
    return answer is MultipleChoiceAnswer && answer.choices == choices;
  }

}