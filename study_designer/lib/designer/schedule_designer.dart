import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:provider/provider.dart';
import 'package:studyou_core/models/models.dart';
import 'package:studyou_core/models/study_schedule/study_schedule.dart';

import '../models/designer_state.dart';

class ScheduleDesigner extends StatefulWidget {
  @override
  _ScheduleDesignerState createState() => _ScheduleDesignerState();
}

class _ScheduleDesignerState extends State<ScheduleDesigner> {
  StudyBase _draftStudy;
  final GlobalKey<FormBuilderState> _editFormKey = GlobalKey<FormBuilderState>();

  @override
  void initState() {
    super.initState();
    _draftStudy = context.read<DesignerState>().draftStudy;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: SingleChildScrollView(
        child: FormBuilder(
          key: _editFormKey,
          autovalidate: true,
          child: Column(
            children: <Widget>[
              FormBuilderTextField(
                  onChanged: _saveFormChanges,
                  name: 'numberOfCycles',
                  decoration: InputDecoration(labelText: 'Number of Cycles'),
                  initialValue: _draftStudy.studyDetails.schedule.numberOfCycles.toString()),
              FormBuilderTextField(
                  onChanged: _saveFormChanges,
                  name: 'phaseDuration',
                  decoration: InputDecoration(labelText: 'Phase Duration'),
                  initialValue: _draftStudy.studyDetails.schedule.phaseDuration.toString()),
              FormBuilderSwitch(
                  onChanged: _saveFormChanges,
                  title: Text('Include Baseline'),
                  name: 'includeBaseline',
                  initialValue: _draftStudy.studyDetails.schedule.includeBaseline),
              FormBuilderDropdown(
                onChanged: _saveFormChanges,
                name: 'sequence',
                decoration: InputDecoration(labelText: 'Sequence'),
                initialValue: _draftStudy.studyDetails.schedule.sequence,
                items: PhaseSequence.values
                    .map((sequence) => DropdownMenuItem(
                        value: sequence,
                        child: Text(sequence.toString().substring(sequence.toString().indexOf('.') + 1))))
                    .toList(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _saveFormChanges(value) {
    _editFormKey.currentState.save();
    if (_editFormKey.currentState.validate()) {
      setState(() {
        _draftStudy.studyDetails.schedule
          ..numberOfCycles = int.parse(_editFormKey.currentState.value['numberOfCycles'])
          ..phaseDuration = int.parse(_editFormKey.currentState.value['phaseDuration'])
          ..includeBaseline = _editFormKey.currentState.value['includeBaseline']
          ..sequence = _editFormKey.currentState.value['sequence'];
      });
    }
  }
}
