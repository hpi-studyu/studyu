import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:study_designer/designer/interventions_designer/intervention_card.dart';
import 'package:studyou_core/models/interventions/intervention.dart';
import 'package:uuid/uuid.dart';

import '../../models/designer_state.dart';

class InterventionsDesigner extends StatefulWidget {
  @override
  _InterventionsDesignerState createState() => _InterventionsDesignerState();
}

class _InterventionsDesignerState extends State<InterventionsDesigner> {
  List<Intervention> _interventions;

  void _addIntervention() {
    final intervention = Intervention(Uuid().v4(), '')
      ..name = ''
      ..description = ''
      ..tasks = [];
    setState(() {
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
    _interventions = context.watch<DesignerModel>().draftStudy.studyDetails.interventionSet.interventions;
    return Padding(
      padding: const EdgeInsets.all(16),
      child: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            ..._interventions
                .asMap()
                .entries
                .map((entry) => InterventionCard(
                    key: UniqueKey(), intervention: entry.value, remove: () => _removeIntervention(entry.key)))
                .toList(),
            RaisedButton.icon(
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
