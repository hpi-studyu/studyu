import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

import '../database/models/questionnaire/answers/multiple_choice_answer.dart';
import '../database/models/questionnaire/questions/multiple_choice_question.dart';

class MultipleChoiceQuestionWidget extends StatefulWidget {

  final MultipleChoiceQuestion question;

  MultipleChoiceQuestionWidget({Key key, @required this.question});

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
  State<MultipleChoiceQuestionWidget> createState() => _MultipleChoiceQuestionWidgetState(question);

}

class _MultipleChoiceQuestionWidgetState extends State<MultipleChoiceQuestionWidget> {
  List<Choice> selected = [];
  final MultipleChoiceQuestion multiQuestion;

  _MultipleChoiceQuestionWidgetState(this.multiQuestion);

  void finishAnswering() {
    widget.onDone(
      MultipleChoiceAnswer(
        multiQuestion.id,
        DateTime.now(),
        multiQuestion.id,
        selected.toSet(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final choiceWidgets = multiQuestion.choices
        .map<Widget>((choice) => GestureDetector(
            onTap: () => null,
            child: Card(
              child: ListTile(
                title: Text(choice.value),
                trailing: Visibility(
                  maintainSize: true,
                  visible: false,
                  child: Icon(MdiIcons.checkboxMarked),
                ),
              ),
            )))
        .toList();
    //TODO translate
    final selectionComment = 'Select ${multiQuestion.multiple ? 'at least ' : ''}1';
    return Column(
        mainAxisSize: MainAxisSize.min,
        children: choiceWidgets,
      );
  }
}
