import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

import '../database/models/questionnaire/answers/answer.dart';
import '../database/models/questionnaire/questions/multiple_choice_question.dart';
import 'question_widget.dart';

class MultipleChoiceQuestionWidget extends QuestionWidget {

  MultipleChoiceQuestionWidget({Key key, @required MultipleChoiceQuestion question, @required Function(Answer) onDone})
      : super(key: key, onDone: onDone, question: question);

  /*MultipleChoiceQuestionWidget.fromQuestion(MultipleChoiceQuestion question) {
    final choices = <RPChoice>[];
    for (var choice in question.choices) {
      final choiceStep = RPChoice.withParams(choice.value, choice.id);
      choices.add(choiceStep);
    }
    final answerFormat = RPChoiceAnswerFormat.withParams(
        question.multiple
            ? ChoiceAnswerStyle.MultipleChoice
            : ChoiceAnswerStyle.SingleChoice,
        choices);
    return RPQuestionStep.withAnswerFormat('${question.id}', question.question, answerFormat);
  }*/

  @override
  State<MultipleChoiceQuestionWidget> createState() => _MultipleChoiceQuestionWidgetState();
}

class _MultipleChoiceQuestionWidgetState extends State<MultipleChoiceQuestionWidget> {
  @override
  Widget build(BuildContext context) {
    final multipleChoiceQuestion = widget.question as MultipleChoiceQuestion;
    final choiceWidgets = multipleChoiceQuestion.choices.map<Widget>((choice) => Card(
      child: Text(choice.value),
    )).toList();
    return widget.getCompleteQuestion(
      Column(
        mainAxisSize: MainAxisSize.min,
        children: choiceWidgets,
      )
    );
  }
}
