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
  int selectedInterventionIndex;

  @override
  void initState() {
    super.initState();
    selectedInterventionIndex = null;
  }

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
    _interventions = context.watch<DesignerModel>().draftStudy.studyDetails.interventions;
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
                      removeIntervention: _removeIntervention,
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
