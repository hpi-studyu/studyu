import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:studyu_core/core.dart';

import 'choice_editor.dart';

class ChoiceQuestionEditorSection extends StatefulWidget {
  final ChoiceQuestion question;

  const ChoiceQuestionEditorSection({@required this.question, Key key}) : super(key: key);

  @override
  _ChoiceQuestionEditorSectionState createState() => _ChoiceQuestionEditorSectionState();
}

class _ChoiceQuestionEditorSectionState extends State<ChoiceQuestionEditorSection> {
  void _addChoice() {
    setState(() {
      final choice = Choice.withId();
      widget.question.choices.add(choice);
    });
  }

  void _removeChoice(int index) {
    setState(() {
      widget.question.choices.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Text(AppLocalizations.of(context).multiple),
            const SizedBox(width: 10),
            Switch(
              value: widget.question.multiple,
              onChanged: (value) {
                setState(() {
                  widget.question.multiple = value;
                });
              },
            )
          ],
        ),
        ListView.builder(
          shrinkWrap: true,
          itemCount: widget.question.choices.length,
          itemBuilder: (buildContext, index) {
            return ChoiceEditor(
              key: UniqueKey(),
              choice: widget.question.choices[index],
              remove: () => _removeChoice(index),
            );
          },
        ),
        Row(
          children: [
            const Spacer(),
            ElevatedButton.icon(
              onPressed: _addChoice,
              icon: const Icon(Icons.add),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
              label: Text(AppLocalizations.of(context).add_choice),
            ),
            const Spacer()
          ],
        )
      ],
    );
  }
}
