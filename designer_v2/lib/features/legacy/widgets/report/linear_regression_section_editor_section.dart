import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:provider/provider.dart';
import 'package:studyu_core/core.dart';
import 'package:studyu_designer_v2/features/legacy/designer/app_state.dart';

import '../util/data_reference_editor.dart';

class LinearRegressionSectionEditorSection extends StatefulWidget {
  final LinearRegressionSection section;

  const LinearRegressionSectionEditorSection({required this.section, Key? key}) : super(key: key);

  @override
  _LinearRegressionSectionEditorSectionState createState() => _LinearRegressionSectionEditorSectionState();
}

class _LinearRegressionSectionEditorSectionState extends State<LinearRegressionSectionEditorSection> {
  final GlobalKey<FormBuilderState> _editFormKey = GlobalKey<FormBuilderState>();

  @override
  Widget build(BuildContext context) {
    final study = context.watch<AppState>().draftStudy!;
    final tasks = <Task>[
      ...study.interventions.expand((intervention) => intervention.tasks),
      ...study.observations,
    ];

    return Column(
      children: [
        Row(
          children: [
            const Text('Improvement Direction:'),
            const SizedBox(width: 10),
            DropdownButton<ImprovementDirection>(
              value: widget.section.improvement,
              onChanged: _changeImprovement,
              items: ImprovementDirection.values
                  .map(
                    (aggregation) => DropdownMenuItem(
                      value: aggregation,
                      child: Text(aggregation.toString().substring(aggregation.toString().indexOf('.') + 1)),
                    ),
                  )
                  .toList(),
            )
          ],
        ),
        FormBuilder(
          key: _editFormKey,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          // readonly: true,
          child: Column(
            children: <Widget>[
              FormBuilderTextField(
                onChanged: _changeAlpha,
                name: AppLocalizations.of(context)!.alpha,
                decoration: InputDecoration(labelText: AppLocalizations.of(context)!.alpha_confidence),
                initialValue: widget.section.alpha.toString(),
                validator: FormBuilderValidators.numeric(),
              ),
            ],
          ),
        ),
        DataReferenceEditor<num>(
          reference: widget.section.resultProperty,
          availableTaks: tasks,
          updateReference: (reference) => setState(() => widget.section.resultProperty = reference),
        ),
      ],
    );
  }

  void _changeImprovement(ImprovementDirection? value) {
    if (value == null) {
      return;
    }
    setState(() {
      widget.section.improvement = value;
    });
  }

  void _changeAlpha(String? value) {
    if (value == null) {
      return;
    }
    _editFormKey.currentState!.save();
    if (_editFormKey.currentState!.validate()) {
      setState(() {
        widget.section.alpha = double.parse(value);
      });
    }
  }
}
