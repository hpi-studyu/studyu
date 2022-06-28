import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:studyu_core/core.dart';
import 'package:studyu_designer_v2/features/legacy/widgets/buttons.dart';

class ChoiceExpressionEditorSection extends StatefulWidget {
  final ChoiceExpression expression;
  final ChoiceQuestion targetQuestion;

  const ChoiceExpressionEditorSection({required this.expression, required this.targetQuestion, Key? key})
      : super(key: key);

  @override
  _ChoiceExpressionEditorSectionState createState() => _ChoiceExpressionEditorSectionState();
}

class _ChoiceExpressionEditorSectionState extends State<ChoiceExpressionEditorSection> {
  late List<Choice> selectedChoices;

  @override
  void initState() {
    selectedChoices = widget.targetQuestion.choices.where((c) => widget.expression.choices.contains(c.id)).toList();
    super.initState();
  }

  void _removeChoice(int index) {
    final choice = selectedChoices[index];
    setState(() {
      selectedChoices.removeAt(index);
      widget.expression.choices.remove(choice.id);
    });
  }

  @override
  Widget build(BuildContext context) {
    final addButton = _buildAddButton();
    return Column(
      children: [
        ListView.builder(
          shrinkWrap: true,
          itemCount: widget.expression.choices.length,
          itemBuilder: (buildContext, index) {
            return Row(
              children: [
                Expanded(child: Text(selectedChoices[index].text)),
                Expanded(
                  child: ButtonBar(
                    children: <Widget>[
                      DeleteButton(onPressed: () => _removeChoice(index)),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
        if (addButton != null) addButton
      ],
    );
  }

  Widget? _buildAddButton() {
    if (selectedChoices.length < widget.targetQuestion.choices.length) {
      return Row(
        children: [
          Text(AppLocalizations.of(context)!.add_choice),
          const SizedBox(width: 10),
          DropdownButton<Choice>(
            onChanged: (choice) {
              setState(() {
                widget.expression.choices.add(choice!.id);
                selectedChoices.add(choice);
              });
            },
            items: widget.targetQuestion.choices
                .where((choice) => !selectedChoices.contains(choice))
                .toList()
                .map((choice) => DropdownMenuItem(value: choice, child: Text(choice.text)))
                .toList(),
          )
        ],
      );
    } else {
      return null;
    }
  }
}
