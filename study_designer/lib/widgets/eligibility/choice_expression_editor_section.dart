import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:studyou_core/models/expressions/types/choice_expression.dart';
import 'package:studyou_core/models/models.dart';

class ChoiceExpressionEditorSection extends StatefulWidget {
  final ChoiceExpression expression;
  final ChoiceQuestion targetQuestion;

  const ChoiceExpressionEditorSection({@required this.expression, @required this.targetQuestion, Key key})
      : super(key: key);

  @override
  _ChoiceExpressionEditorSectionState createState() => _ChoiceExpressionEditorSectionState();
}

class _ChoiceExpressionEditorSectionState extends State<ChoiceExpressionEditorSection> {
  final GlobalKey<FormBuilderState> _editFormKey = GlobalKey<FormBuilderState>();
  bool addButtonActive;

  @override
  void initState() {
    addButtonActive = false;
    super.initState();
  }

  void _removeChoice(String choiceId) {
    setState(() {
      widget.expression.choices.remove(choiceId);
    });
  }

  Choice _getChoiceForId(choiceId) {
    final choices = widget.targetQuestion.choices.where((c) => c.id == choiceId).toList();
    return choices.isNotEmpty ? choices[0] : null;
  }

  @override
  Widget build(BuildContext context) {
    final addButton = _buildAddButton();

    return Column(children: [
      ListView.builder(
        shrinkWrap: true,
        itemCount: widget.expression.choices.length,
        itemBuilder: (buildContext, index) {
          return Text(_getChoiceForId(widget.expression.choices.toList()[index]).text);
        },
      ),
      if (addButton != null) addButton
    ]);
  }

  Widget _buildAddButton() {
    if (widget.expression.choices.length < widget.targetQuestion.choices.length) {
      if (addButtonActive) {
        return FormBuilder(
            key: _editFormKey,
            autovalidate: true,
            // readonly: true,
            child: Column(children: <Widget>[
              FormBuilderDropdown(
                name: 'choice',
                onChanged: (choice) {
                  setState(() {
                    addButtonActive = false;
                    widget.expression.choices.add(choice.id);
                  });
                },
                hint: Text('Select Choice to add'),
                items: widget.targetQuestion.choices
                    .where((choice) => !widget.expression.choices.contains(choice.id))
                    .toList()
                    .map((choice) => DropdownMenuItem(value: choice, child: Text(choice.text)))
                    .toList(),
              ),
            ]));
      } else {
        return Row(children: [
          Spacer(),
          RaisedButton.icon(
              onPressed: () => setState(() => addButtonActive = true),
              icon: Icon(Icons.add),
              color: Colors.green,
              label: Text('Select Choice')),
          Spacer()
        ]);
      }
    } else {
      return null;
    }
  }
}
