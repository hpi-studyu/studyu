import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:study_designer/widgets/eligibility/expression_editor.dart';
import 'package:studyou_core/models/expressions/types/boolean_expression.dart';
import 'package:studyou_core/models/expressions/types/choice_expression.dart';
import 'package:studyou_core/models/models.dart';

class EligibilityCriterionEditor extends StatefulWidget {
  final EligibilityCriterion eligibilityCriterion;
  final List<Question> questions;
  final void Function() remove;

  const EligibilityCriterionEditor(
      {@required this.eligibilityCriterion, @required this.questions, @required this.remove, Key key})
      : super(key: key);

  @override
  _EligibilityCriterionEditorState createState() => _EligibilityCriterionEditorState();
}

class _EligibilityCriterionEditorState extends State<EligibilityCriterionEditor> {
  final GlobalKey<FormBuilderState> _editFormKey = GlobalKey<FormBuilderState>();

  void _changeTarget(newTarget) {
    Expression newExpression;
    if (newTarget == BooleanQuestion.questionType) {
      newExpression = BooleanExpression();
    } else if (newTarget == ChoiceQuestion.questionType) {
      newExpression = ChoiceExpression();
    }
    print('hi');
    setState(() {
      widget.eligibilityCriterion.condition = newExpression;
    });
    print('bye');
  }

  @override
  Widget build(BuildContext context) {
    return Card(
        margin: EdgeInsets.all(10),
        child: Column(children: [
          ListTile(
              title: Row(
                children: [Text('Eligibility Criterion')],
              ),
              trailing: FlatButton(
                onPressed: widget.remove,
                child: const Text('Delete'),
              )),
          Padding(
            padding: const EdgeInsets.all(8),
            child: Column(children: [
              FormBuilder(
                key: _editFormKey,
                autovalidate: true,
                // readonly: true,
                child: Column(
                  children: <Widget>[
                    FormBuilderTextField(
                        onChanged: (value) {
                          saveFormChanges();
                        },
                        name: 'reason',
                        maxLength: 40,
                        decoration: InputDecoration(labelText: 'Reason'),
                        initialValue: widget.eligibilityCriterion.reason),
                  ],
                ),
              ),
              ExpressionEditor(
                  expression: widget.eligibilityCriterion.condition,
                  questions: widget.questions,
                  changeTarget: _changeTarget)
            ]),
          )
        ]));
  }

  void saveFormChanges() {
    _editFormKey.currentState.save();
    if (_editFormKey.currentState.validate()) {
      setState(() {
        widget.eligibilityCriterion.reason = _editFormKey.currentState.value['reason'];
      });
    }
  }
}
