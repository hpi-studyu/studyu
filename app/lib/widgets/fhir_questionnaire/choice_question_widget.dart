import 'package:fhir/r4.dart' as fhir;
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../selectable_button.dart';
import 'question_widget.dart';

class ChoiceQuestionWidget extends QuestionWidget {
  final fhir.QuestionnaireItem question;
  final Function(fhir.QuestionnaireResponseItem) onDone;
  final String multiSelectionText;

  ChoiceQuestionWidget({@required this.question, @required this.onDone, @required this.multiSelectionText});

  @override
  State<ChoiceQuestionWidget> createState() => _ChoiceQuestionWidgetState();

  @override
  String get subtitle => question.repeats?.value ?? false ? multiSelectionText : null;
}

class _ChoiceQuestionWidgetState extends State<ChoiceQuestionWidget> {
  List<fhir.Coding> selected;

  @override
  void initState() {
    super.initState();
    selected = [];
  }

  void tapped(fhir.Coding choice) {
    final isMultiple = widget.question.repeats?.value ?? false;
    setState(() {
      if (!isMultiple) selected.clear();
      if (selected.contains(choice)) {
        selected.remove(choice);
      } else {
        selected.add(choice);
      }
    });
    if (!isMultiple) confirm();
  }

  void confirm() {
    widget.onDone(fhir.QuestionnaireResponseItem(
        linkId: widget.question.linkId,
        answer: selected.map((answer) => fhir.QuestionnaireResponseAnswer(valueCoding: answer)).toList()));
  }

  @override
  Widget build(BuildContext context) {
    final choiceWidgets = widget.question.answerOption
        .map<Widget>((choice) => SelectableButton(
              selected: selected.contains(choice.valueCoding),
              onTap: () => tapped(choice.valueCoding),
              child: Text(choice.valueCoding.display),
            ))
        .toList();

    if (widget.question.repeats?.value ?? false) {
      choiceWidgets.add(ElevatedButton(
        onPressed: confirm,
        style: ElevatedButton.styleFrom(primary: Theme.of(context).colorScheme.secondary),
        child: Text(AppLocalizations.of(context).confirm),
      ));
    }

    return ListView.separated(
      key: widget.key,
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      itemCount: choiceWidgets.length,
      itemBuilder: (context, index) => choiceWidgets[index],
      separatorBuilder: (context, index) => SizedBox(height: 8),
    );
  }
}
