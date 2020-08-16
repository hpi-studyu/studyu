import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:studyou_core/models/models.dart';
import 'package:studyou_core/models/questionnaire/questionnaire.dart';
import 'package:uuid/uuid.dart';

import '../models/designer_state.dart';
import '../widgets/designer_add_button.dart';
import '../widgets/task/task_editor.dart';

class ObservationDesigner extends StatefulWidget {
  @override
  _ObservationDesignerState createState() => _ObservationDesignerState();
}

class _ObservationDesignerState extends State<ObservationDesigner> {
  List<Observation> _observations;

  void _addObservation() {
    final questionnaire = Questionnaire()..questions = [];

    final intervention = QuestionnaireTask()
      ..id = Uuid().v4()
      ..title = ''
      ..schedule = []
      ..questions = questionnaire;
    setState(() {
      _observations.add(intervention);
    });
    print(Observation.taskTypes.keys.toList());
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
        DesignerAddButton(label: Text('Add Observation'), add: _addObservation)
      ],
    );
  }
}
