import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:studyou_core/models/models.dart';
import 'package:studyou_core/util/localization.dart';

import '../models/designer_state.dart';
import '../widgets/task/task_editor.dart';
import '../widgets/util/designer_add_button.dart';

class ObservationDesigner extends StatefulWidget {
  @override
  _ObservationDesignerState createState() => _ObservationDesignerState();
}

class _ObservationDesignerState extends State<ObservationDesigner> {
  List<Observation> _observations;

  void _addObservation() {
    setState(() {
      _observations.add(QuestionnaireTask.designerDefault());
    });
  }

  void _removeObservation(index) {
    setState(() {
      _observations.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    _observations = context.watch<DesignerState>().draftStudy.studyDetails.observations;
    return Stack(
      children: [
        Center(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: SingleChildScrollView(
              child: Column(
                children: <Widget>[
                  ..._observations.asMap().entries.map((entry) =>
                      TaskEditor(key: UniqueKey(), task: entry.value, remove: () => _removeObservation(entry.key)))
                ],
              ),
            ),
          ),
        ),
        DesignerAddButton(label: Text(Nof1Localizations.of(context).translate('add_observation')), add: _addObservation)
      ],
    );
  }
}
