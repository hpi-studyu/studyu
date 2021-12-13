import 'package:fhir/r4.dart' as fhir;
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../selectable_button.dart';
import 'question_widget.dart';

class BooleanQuestionWidget extends QuestionWidget {
  final fhir.QuestionnaireItem question;
  final Function(fhir.QuestionnaireResponseItem) onDone;

  BooleanQuestionWidget({@required this.question, this.onDone});

  @override
  State<BooleanQuestionWidget> createState() => _BooleanQuestionWidgetState();
}

class _BooleanQuestionWidgetState extends State<BooleanQuestionWidget> {
  bool selected;

  @override
  void initState() {
    super.initState();
    selected = null;
  }

  void tapped({bool choice}) {
    setState(() {
      selected = choice;
      widget.onDone(
        fhir.QuestionnaireResponseItem(
          linkId: widget.question.linkId,
          answer: [fhir.QuestionnaireResponseAnswer(valueBoolean: fhir.Boolean(choice))],
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      key: widget.key,
      children: [
        SelectableButton(
          selected: selected == true,
          onTap: () => tapped(choice: true),
          child: Text(AppLocalizations.of(context).yes),
        ),
        const SizedBox(height: 8),
        SelectableButton(
          selected: selected == false,
          onTap: () => tapped(choice: false),
          child: Text(AppLocalizations.of(context).no),
        ),
      ],
    );
  }
}
