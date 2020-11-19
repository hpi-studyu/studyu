import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:studyou_core/models/interventions/intervention.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

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
                        .toList(),
                    SizedBox(height: 200)
                  ],
                ),
              ),
            ),
          ),
        ),
        DesignerAddButton(label: Text(AppLocalizations.of(context).add_intervention), add: _addIntervention)
      ],
    );
  }
}
