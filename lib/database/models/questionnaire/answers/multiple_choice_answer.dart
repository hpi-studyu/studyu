import 'package:collection/collection.dart';

import '../questions/multiple_choice_question.dart';

import 'answer.dart';

class MultipleChoiceAnswer extends Answer {

  static const String answerType = MultipleChoiceQuestion.questionType;
  @override
  String get type => answerType;

  Set<Choice> choices;

  MultipleChoiceAnswer(int id, DateTime timestamp, int questionId, this.choices) : super(id, timestamp, questionId);

  MultipleChoiceAnswer.fromJson(Map<String, dynamic> data) : super.fromJsonScaffold(data) {
    choices = data['choices'];
  }

  @override
  Map<String, dynamic> toJson() => mergeMaps<String, dynamic>(super.toJson(), {
    'choices': choices
  });

}