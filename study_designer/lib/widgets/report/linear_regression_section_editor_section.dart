import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:provider/provider.dart';
import 'package:studyou_core/models/models.dart';
import 'package:studyou_core/util/localization.dart';
import 'package:studyou_core/util/localization.dart';

import '../../models/designer_state.dart';
import '../util/data_reference_editor.dart';

class LinearRegressionSectionEditorSection extends StatefulWidget {
  final LinearRegressionSection section;

  const LinearRegressionSectionEditorSection({@required this.section, Key key}) : super(key: key);

  @override
  _LinearRegressionSectionEditorSectionState createState() => _LinearRegressionSectionEditorSectionState();
}

class _LinearRegressionSectionEditorSectionState extends State<LinearRegressionSectionEditorSection> {
  final GlobalKey<FormBuilderState> _editFormKey = GlobalKey<FormBuilderState>();

  @override
  Widget build(BuildContext context) {
    final studyDetails = context.watch<DesignerState>().draftStudy.studyDetails;
    final tasks = <Task>[
      ...studyDetails.interventionSet.interventions.expand((intervention) => intervention.tasks),
      ...studyDetails.observations,
    ];

    return Column(children: [
      Row(children: [
        Text('Improvement Direction:'),
        SizedBox(width: 10),
        DropdownButton<ImprovementDirection>(
          value: widget.section.improvement,
          onChanged: _changeImprovement,
          items: ImprovementDirection.values
              .map((aggregation) => DropdownMenuItem(
                  value: aggregation,
                  child: Text(aggregation.toString().substring(aggregation.toString().indexOf('.') + 1))))
              .toList(),
        )
      ]),
      FormBuilder(
        key: _editFormKey,
        autovalidate: true,
        // readonly: true,
        child: Column(children: <Widget>[
          FormBuilderTextField(
            onChanged: _changeAlpha,
            name: Nof1Localizations.of(context).translate('alpha'),
            decoration: InputDecoration(labelText: Nof1Localizations.of(context).translate('alpha_confidence')),
            initialValue: widget.section.alpha.toString(),
            validator: FormBuilderValidators.numeric(context),
          ),
        ]),
      ),
      DataReferenceEditor<num>(
          reference: widget.section.resultProperty,
          availableTaks: tasks,
          updateReference: (reference) => setState(() => widget.section.resultProperty = reference)),
    ]);
  }

  void _changeImprovement(value) {
    setState(() {
      widget.section.improvement = value;
    });
  }

  void _changeAlpha(value) {
    _editFormKey.currentState.save();
    if (_editFormKey.currentState.validate()) {
      setState(() {
        widget.section.alpha = value;
      });
    }
  }
}
