import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:studyu_core/core.dart';
import 'package:provider/provider.dart';
import 'package:studyu_designer_v2/features/legacy/designer/app_state.dart';
import 'choice_editor.dart';

class ChoiceQuestionEditorSection extends StatefulWidget {
  final ChoiceQuestion question;

  const ChoiceQuestionEditorSection({required this.question, Key? key}) : super(key: key);

  @override
  _ChoiceQuestionEditorSectionState createState() => _ChoiceQuestionEditorSectionState();
}

class _ChoiceQuestionEditorSectionState extends State<ChoiceQuestionEditorSection> {
  void _addChoice() {
    setState(() {
      final choice = Choice.withId();
      widget.question.choices.add(choice);
    });
    context.read<AppState>().updateDelegate();
  }

  void _removeChoice(int index) {
    setState(() {
      widget.question.choices.removeAt(index);
    });
    context.read<AppState>().updateDelegate();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Text(AppLocalizations.of(context)!.multiple),
            const SizedBox(width: 10),
            Switch(
              value: widget.question.multiple,
              onChanged: (value) {
                setState(() {
                  widget.question.multiple = value;
                });
                context.read<AppState>().updateDelegate();
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
              style: ElevatedButton.styleFrom(primary: Colors.green),
              label: Text(AppLocalizations.of(context)!.add_choice),
            ),
            const Spacer()
          ],
        )
      ],
    );
  }
}
