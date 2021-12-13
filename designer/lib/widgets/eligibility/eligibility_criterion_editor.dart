import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:studyu_core/core.dart';
import 'package:studyu_designer/widgets/buttons.dart';

import './expression_editor.dart';

class EligibilityCriterionEditor extends StatefulWidget {
  final EligibilityCriterion eligibilityCriterion;
  final List<Question> questions;
  final void Function() remove;

  const EligibilityCriterionEditor({
    @required this.eligibilityCriterion,
    @required this.questions,
    @required this.remove,
    Key key,
  }) : super(key: key);

  @override
  _EligibilityCriterionEditorState createState() => _EligibilityCriterionEditorState();
}

class _EligibilityCriterionEditorState extends State<EligibilityCriterionEditor> {
  final GlobalKey<FormBuilderState> _editFormKey = GlobalKey<FormBuilderState>();

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(10),
      child: Column(
        children: [
          ListTile(
            title: Row(
              children: [Text(AppLocalizations.of(context).eligibility_criterion)],
            ),
            trailing: DeleteButton(onPressed: widget.remove),
          ),
          Padding(
            padding: const EdgeInsets.all(8),
            child: Column(
              children: [
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
                        decoration: InputDecoration(labelText: AppLocalizations.of(context).reason),
                        initialValue: widget.eligibilityCriterion.reason,
                      ),
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
                  },
                )
              ],
            ),
          )
        ],
      ),
    );
  }

  void saveFormChanges() {
    _editFormKey.currentState.save();
    if (_editFormKey.currentState.validate()) {
      setState(() {
        widget.eligibilityCriterion.reason = _editFormKey.currentState.value['reason'] as String;
      });
    }
  }
}
