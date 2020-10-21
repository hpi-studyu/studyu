import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:studyou_core/models/models.dart';
import 'package:studyou_core/models/study_results/results/numeric_result.dart';

import '../../models/designer_state.dart';
import '../util/data_reference_editor.dart';

class NumericResultEditorSection extends StatefulWidget {
  final NumericResult result;

  const NumericResultEditorSection({@required this.result, Key key}) : super(key: key);

  @override
  _NumericResultEditorSectionState createState() => _NumericResultEditorSectionState();
}

class _NumericResultEditorSectionState extends State<NumericResultEditorSection> {
  @override
  Widget build(BuildContext context) {
    final studyDetails = context.watch<DesignerState>().draftStudy.studyDetails;
    final tasks = <Task>[
      ...studyDetails.interventionSet.interventions.expand((intervention) => intervention.tasks),
      ...studyDetails.observations,
    ];

    return Column(children: [
      DataReferenceEditor<num>(
          reference: widget.result.resultProperty,
          availableTaks: tasks,
          updateReference: (reference) => setState(() => widget.result.resultProperty = reference))
    ]);
  }
}
