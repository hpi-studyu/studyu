import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:studyou_core/models/models.dart';
import 'package:studyou_core/util/localization.dart';

import './expression_editor.dart';

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

  @override
  Widget build(BuildContext context) {
    return Card(
        margin: EdgeInsets.all(10),
        child: Column(children: [
          ListTile(
              title: Row(
                children: [Text(Nof1Localizations.of(context).translate('eligibility_criterion'))],
              ),
              trailing: FlatButton(
                onPressed: widget.remove,
                child: Text(Nof1Localizations.of(context).translate('delete')),
              )),
          Padding(
            padding: const EdgeInsets.all(8),
            child: Column(children: [
              FormBuilder(
                key: _editFormKey,
                autovalidateMode: AutovalidateMode.onUserInteraction,
                // readonly: true,
                child: Column(
                  children: <Widget>[
                    FormBuilderTextField(
                        onChanged: (value) {
                          saveFormChanges();
                        },
                        name: 'reason',
                        decoration: InputDecoration(labelText: Nof1Localizations.of(context).translate('reason')),
                        initialValue: widget.eligibilityCriterion.reason),
                  ],
                ),
              ),
              ExpressionEditor(
                  expression: widget.eligibilityCriterion.condition,
                  questions: widget.questions,
                  updateExpression: (newExpression) {
                    setState(() {
                      widget.eligibilityCriterion.condition = newExpression;
                    });
                  })
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
