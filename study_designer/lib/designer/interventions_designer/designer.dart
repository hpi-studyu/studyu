import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:study_designer/designer/interventions_designer/intervention_card.dart';

import '../../models/designer_state.dart';

class InterventionsDesigner extends StatefulWidget {
  @override
  _InterventionsDesignerState createState() => _InterventionsDesignerState();
}

const String keyInterventionName = 'intervention_name_';
const String keyInterventionDescription = 'intervention_description_';

class _InterventionsDesignerState extends State<InterventionsDesigner> {
  List<LocalIntervention> _interventions;

  void _addIntervention() {
    setState(() {
      final intervention = LocalIntervention()
        ..name = ''
        ..description = ''
        ..tasks = [];
      _interventions.add(intervention);
    });
  }

  void _removeIntervention(index) {
    setState(() {
      _interventions.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    _interventions = context.watch<DesignerModel>().draftStudy.studyDetails.interventions;
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.all(16),
      child: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            ..._interventions
                .asMap()
                .entries
                .map((entry) => InterventionCard(interventionIndex: entry.key, removeIntervention: _removeIntervention))
                .toList(),
            RaisedButton.icon(
                textTheme: ButtonTextTheme.primary,
                onPressed: _addIntervention,
                icon: Icon(Icons.add),
                color: Colors.green,
                label: Text('Add Intervention')),
          ],
        ),
      ),
    );
  }
}
