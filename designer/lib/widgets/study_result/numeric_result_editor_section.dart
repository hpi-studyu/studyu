import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:studyu_core/core.dart';
import 'package:studyu_designer/models/app_state.dart';

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
    final study = context.watch<AppState>().draftStudy;
    final tasks = <Task>[
      ...study.interventions.expand((intervention) => intervention.tasks),
      ...study.observations,
    ];

    return Column(
      children: [
        DataReferenceEditor<num>(
          reference: widget.result.resultProperty,
          availableTaks: tasks,
          updateReference: (reference) => setState(() => widget.result.resultProperty = reference),
        )
      ],
    );
  }
}
