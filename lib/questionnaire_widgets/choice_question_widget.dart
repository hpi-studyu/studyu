import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

import '../database/models/questionnaire/answer.dart';
import '../database/models/questionnaire/questions/choice_question.dart';
import '../widgets/selectable_button.dart';
import 'question_widget.dart';

class ChoiceQuestionWidget extends QuestionWidget {
  final ChoiceQuestion question;
  final Function(Answer) onDone;

  ChoiceQuestionWidget({Key key, @required this.question, this.onDone});

  @override
  State<ChoiceQuestionWidget> createState() => _ChoiceQuestionWidgetState();

  @override
  // TODO: Translate
  String get subtitle => question.multiple ? 'Select all that apply' : null;
}

class _ChoiceQuestionWidgetState extends State<ChoiceQuestionWidget> {
  List<Choice> selected;

  @override
  void initState() {
    super.initState();
    selected = [];
  }

  void tapped(Choice choice) {
    setState(() {
      if (!widget.question.multiple) selected.clear();
      if (selected.contains(choice)) {
        selected.remove(choice);
      } else {
        selected.add(choice);
      }
    });
    if (!widget.question.multiple) confirm();
  }

  void confirm() {
    widget.onDone(widget.question.constructAnswer(selected));
  }

  @override
  Widget build(BuildContext context) {
    final choiceWidgets = widget.question.choices.map<Widget>((choice) =>
        SelectableButton(
          selected: selected.contains(choice),
          onTap: () => tapped(choice),
          child: Text(choice.text),
        )
    ).toList();

    if (widget.question.multiple) {
      choiceWidgets.add(
          RaisedButton(
            onPressed: confirm,
            // TODO: Translate
            child: Text('Done'),
          )
      );
    }

    return ListView.separated(
      shrinkWrap: true,
      itemCount: choiceWidgets.length,
      itemBuilder: (context, index) => choiceWidgets[index],
      separatorBuilder: (context, index) => SizedBox(height: 8.0),
    );
  }
}
