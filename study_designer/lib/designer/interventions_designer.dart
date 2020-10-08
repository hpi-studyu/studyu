import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:studyou_core/models/interventions/intervention.dart';
import 'package:studyou_core/util/localization.dart';

import '../models/designer_state.dart';
import '../widgets/intervention/intervention_editor.dart';
import '../widgets/util/designer_add_button.dart';

class InterventionsDesigner extends StatefulWidget {
  @override
  _InterventionsDesignerState createState() => _InterventionsDesignerState();
}

class _InterventionsDesignerState extends State<InterventionsDesigner> {
  List<Intervention> _interventions;

  void _addIntervention() {
    setState(() {
      _interventions.add(Intervention.designerDefault());
    });
  }

  void _removeIntervention(index) {
    setState(() {
      _interventions.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    _interventions = context.watch<DesignerState>().draftStudy.studyDetails.interventionSet.interventions;
    final theme = Theme.of(context);
    return Stack(
      children: [
        Center(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Scrollbar(
              child: SingleChildScrollView(
                child: Column(
                  children: <Widget>[
                    ..._interventions
                        .asMap()
                        .entries
                        .map((entry) => InterventionEditor(
                            key: UniqueKey(), intervention: entry.value, remove: () => _removeIntervention(entry.key)))
                        .toList()
                  ],
                ),
              ),
            ),
          ),
        ),
        DesignerAddButton(
            label: Text(Nof1Localizations.of(context).translate('add_intervention')), add: _addIntervention)
      ],
    );
  }
}
