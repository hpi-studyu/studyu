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
  int selectedInterventionIndex;

  @override
  void initState() {
    super.initState();
    selectedInterventionIndex = null;
  }

  void _addIntervention() {
    setState(() {
      final intervention = Intervention(Uuid().v4(), '')
        ..name = ''
        ..description = ''
        ..tasks = [];
      _interventions.add(intervention);
    });
  }

  void _removeIntervention(index) {
    setState(() {
      _interventions.removeAt(index);
      selectedInterventionIndex = null;
    });
  }

  void _selectIntervention(index) {
    setState(() {
      selectedInterventionIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    _interventions = context.watch<DesignerModel>().draftStudy.studyDetails.interventionSet.interventions;
    final theme = Theme.of(context);
    return GestureDetector(
      onTap: () => setState(() => selectedInterventionIndex = null),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Column(
            children: <Widget>[
              ..._interventions
                  .asMap()
                  .entries
                  .map((entry) => InterventionCard(
                      interventionIndex: entry.key,
                      remove: _removeIntervention,
                      isEditing: entry.key == selectedInterventionIndex,
                      onTap: _selectIntervention))
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
      ),
    );
  }
}
