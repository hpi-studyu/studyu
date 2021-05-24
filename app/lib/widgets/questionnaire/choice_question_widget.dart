import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:studyou_core/core.dart';

import '../selectable_button.dart';
import 'question_widget.dart';

class ChoiceQuestionWidget extends QuestionWidget {
  final ChoiceQuestion question;
  final Function(Answer) onDone;
  final String multiSelectionText;

  ChoiceQuestionWidget({@required this.question, @required this.onDone, @required this.multiSelectionText});

  @override
  State<ChoiceQuestionWidget> createState() => _ChoiceQuestionWidgetState();

  @override
  String get subtitle => question.multiple ? multiSelectionText : null;
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
      choiceWidgets.add(OutlinedButton(
        onPressed: confirm,
        style: ButtonStyle(
            backgroundColor: MaterialStateProperty.all<Color>(Theme.of(context).accentColor),
            foregroundColor: MaterialStateProperty.all<Color>(Colors.white)),
        child: Text(AppLocalizations.of(context).confirm),
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
