import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:studyou_core/models/expressions/types/choice_expression.dart';
import 'package:studyou_core/models/models.dart';
import 'package:studyou_core/util/localization.dart';

class ChoiceExpressionEditorSection extends StatefulWidget {
  final ChoiceExpression expression;
  final ChoiceQuestion targetQuestion;

  const ChoiceExpressionEditorSection({@required this.expression, @required this.targetQuestion, Key key})
      : super(key: key);

  @override
  _ChoiceExpressionEditorSectionState createState() => _ChoiceExpressionEditorSectionState();
}

class _ChoiceExpressionEditorSectionState extends State<ChoiceExpressionEditorSection> {
  List<Choice> selectedChoices;

  @override
  void initState() {
    selectedChoices = widget.targetQuestion.choices.where((c) => widget.expression.choices.contains(c.id)).toList();
    super.initState();
  }

  void _removeChoice(index) {
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
            return Row(children: [
              Expanded(child: Text(selectedChoices[index].text)),
              Expanded(
                child: ButtonBar(
                  children: <Widget>[
                    FlatButton(
                      onPressed: () => _removeChoice(index),
                      child: Text(Nof1Localizations.of(context).translate('delete')),
                    ),
                  ],
                ),
              ),
            ]);
          },
        ),
        if (addButton != null) addButton
      ],
    );
  }

  Widget _buildAddButton() {
    if (selectedChoices.length < widget.targetQuestion.choices.length) {
      return Row(children: [
        Text(Nof1Localizations.of(context).translate('add_choice')),
        SizedBox(width: 10),
        DropdownButton<Choice>(
            onChanged: (choice) {
              setState(() {
                widget.expression.choices.add(choice.id);
                selectedChoices.add(choice);
              });
            },
            items: widget.targetQuestion.choices
                .where((choice) => !selectedChoices.contains(choice))
                .toList()
                .map((choice) => DropdownMenuItem(value: choice, child: Text(choice.text)))
                .toList())
      ]);
    } else {
      return null;
    }
  }
}
