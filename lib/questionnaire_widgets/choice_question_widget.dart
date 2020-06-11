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
  List<Choice> selected = [];
  int maxSelection;
  final List<Widget> _questionFooter = [];

  @override
  void initState() {
    super.initState();
    if (widget.question.multiple) {
      _questionFooter.add(RaisedButton(
        onPressed: confirm,
        // TODO: Translate
        child: Text('Done'),
      ));
    }
  }

  void tapped(Choice choice) {
    setState(() {
      if (!widget.question.multiple) {
        selected.clear();
      }
      if (selected.contains(choice)) {
        selected.remove(choice);
      } else {
        selected.add(choice);
      }
    });
    if (!widget.question.multiple) {
      confirm();
    }
  }

  void confirm() {
    widget.onDone(widget.question.constructAnswer(selected));
  }

  @override
  Widget build(BuildContext context) {
    final choiceWidgets = widget.question.choices
        .expand<Widget>((choice) => [
              SizedBox(height: 8),
              SelectableButton(
                selected: selected.contains(choice),
                onTap: () => tapped(choice),
                child: Text(choice.text),
              ),
            ])
        .skip(1) // Skip first SizedBox
        .toList();

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        ...choiceWidgets,
        ..._questionFooter,
      ],
    );
  }
}
