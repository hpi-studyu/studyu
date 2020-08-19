import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:studyou_core/models/models.dart';

import '../../util/localization.dart';
import '../selectable_button.dart';
import 'question_widget.dart';

class ChoiceQuestionWidget extends QuestionWidget {
  final ChoiceQuestion question;
  final Function(Answer) onDone;

  ChoiceQuestionWidget({@required this.question, this.onDone});

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
    final choiceWidgets = widget.question.choices
        .map<Widget>((choice) => SelectableButton(
              selected: selected.contains(choice),
              onTap: () => tapped(choice),
              child: Text(choice.text),
            ))
        .toList();

    if (widget.question.multiple) {
      choiceWidgets.add(RaisedButton(
        color: Theme.of(context).accentColor,
        textColor: Colors.white,
        onPressed: confirm,
        child: Text(Nof1Localizations.of(context).translate('confirm')),
      ));
    }

    return ListView.separated(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      itemCount: choiceWidgets.length,
      itemBuilder: (context, index) => choiceWidgets[index],
      separatorBuilder: (context, index) => SizedBox(height: 8),
    );
  }
}
