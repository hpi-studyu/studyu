import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:studyou_core/models/models.dart';
import 'package:studyou_core/models/report/temporal_aggregation.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../models/designer_state.dart';
import '../util/data_reference_editor.dart';

class AverageSectionEditorSection extends StatefulWidget {
  final AverageSection section;

  const AverageSectionEditorSection({@required this.section, Key key}) : super(key: key);

  @override
  _AverageSectionEditorSectionState createState() => _AverageSectionEditorSectionState();
}

class _AverageSectionEditorSectionState extends State<AverageSectionEditorSection> {
  @override
  Widget build(BuildContext context) {
    final studyDetails = context.watch<DesignerState>().draftStudy.studyDetails;
    final tasks = <Task>[
      ...studyDetails.interventionSet.interventions.expand((intervention) => intervention.tasks),
      ...studyDetails.observations,
    ];

    return Column(children: [
      Row(children: [
        Text(AppLocalizations.of(context).Temporal Aggregation),
        SizedBox(width: 10),
        DropdownButton<TemporalAggregation>(
          value: widget.section.aggregate,
          onChanged: _changeAggregation,
          items: TemporalAggregation.values
              .map((aggregation) => DropdownMenuItem(
                  value: aggregation,
                  child: Text(aggregation.toString().substring(aggregation.toString().indexOf('.') + 1))))
              .toList(),
        )
      ]),
      DataReferenceEditor<num>(
          reference: widget.section.resultProperty,
          availableTaks: tasks,
          updateReference: (reference) => setState(() => widget.section.resultProperty = reference)),
    ]);
  }

  void _changeAggregation(value) {
    setState(() {
      widget.section.aggregate = value;
    });
  }
}
