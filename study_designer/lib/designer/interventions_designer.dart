import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:provider/provider.dart';

import '../models/designer_state.dart';

class InterventionsDesigner extends StatefulWidget {
  @override
  _InterventionsDesignerState createState() => _InterventionsDesignerState();
}

const String keyInterventionName = 'intervention_name_';
const String keyInterventionDescription = 'intervention_description_';

class _InterventionsDesignerState extends State<InterventionsDesigner> {
  List<LocalIntervention> _interventions;

  final GlobalKey<FormBuilderState> _editFormKey = GlobalKey<FormBuilderState>();

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

  void _addCheckMarkTask(index) {
    setState(() {
      final task = LocalCheckMarkTask()
        ..name = ''
        ..description = ''
        ..schedules = [];
      _interventions[index].tasks.add(task);
    });
    print(_interventions[index].tasks);
  }

  void _removeTask(interventionIndex, taskIndex) {
    setState(() {
      _interventions[interventionIndex].tasks.removeAt(taskIndex);
    });
  }

  void _addFixedSchedule(interventionIndex, taskIndex) {
    setState(() {
      final schedule = LocalFixedSchedule()
        ..hour = 0
        ..minute = 0;
      _interventions[interventionIndex].tasks[taskIndex].schedules.add(schedule);
    });
  }

  void _removeSchedule(interventionIndex, taskIndex, scheduleIndex) {
    setState(() {
      _interventions[interventionIndex].tasks[taskIndex].schedules.removeAt(scheduleIndex);
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
            ..._interventions.asMap().entries.map((entry) => _buildInterventionCard(entry.key, entry.value)).toList(),
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

  Widget _buildInterventionCard(index, intervention) {
    return Container(
      margin: EdgeInsets.all(10.0),
      child: Card(
        child: Column(children: [
          ButtonBar(
            children: <Widget>[
              FlatButton(
                onPressed: () {
                  _showEditInterventionDialog(index);
                },
                child: const Text('Edit'),
              ),
              FlatButton(
                onPressed: () {
                  _removeIntervention(index);
                },
                child: const Text('Delete'),
              ),
            ],
          ),
          ListTile(
            title: Text(intervention.name.isEmpty ? 'Name' : intervention.name),
            subtitle: Text(intervention.description.isEmpty ? 'Description' : intervention.description),
          ),
          SizedBox(height: 10),
          Text(
            'Tasks',
            style: Theme.of(context).textTheme.subtitle1,
          ),
          ...intervention.tasks.asMap().entries.map((entry) => _buildTaskCard(index, entry.key, entry.value)).toList(),
          ButtonBar(
            children: <Widget>[
              FlatButton(
                onPressed: () {
                  _addCheckMarkTask(index);
                },
                child: const Text('Add checkmark task'),
              ),
            ],
          ),
        ]),
      ),
    );
  }

  Widget _buildTaskCard(interventionIndex, index, task) {
    return Container(
        margin: EdgeInsets.all(10.0),
        child: Card(
            child: Column(
          children: [
            Text('Checkmark Task'),
            ButtonBar(
              children: <Widget>[
                FlatButton(
                  onPressed: () {
                    _showEditTaskDialog(interventionIndex, index);
                  },
                  child: const Text('Edit'),
                ),
                FlatButton(
                  onPressed: () {
                    _removeTask(interventionIndex, index);
                  },
                  child: const Text('Delete'),
                ),
              ],
            ),
            ListTile(
              title: Text(task.name.isEmpty ? 'Name' : task.name),
              subtitle: Text(task.description.isEmpty ? 'Description' : task.description),
            ),
            ...task.schedules
                .asMap()
                .entries
                .map((entry) => _buildScheduleCard(interventionIndex, index, entry.key, entry.value))
                .toList(),
            ButtonBar(
              children: <Widget>[
                FlatButton(
                  onPressed: () {
                    _addFixedSchedule(interventionIndex, index);
                  },
                  child: const Text('Add fixed schedule'),
                ),
              ],
            ),
          ],
        )));
  }

  Widget _buildScheduleCard(interventionIndex, taskIndex, index, schedule) {
    return Container(margin: EdgeInsets.all(10.0), child: Card(child: Column(children: [Text('Fixed Schedule')])));
  }

  void _showEditInterventionDialog(index) {
    showDialog(
        context: context,
        builder: (context) {
          return _buildEditDialog(context, index);
        });
  }

  Widget _buildEditDialog(context, index) {
    return AlertDialog(
      content: FormBuilder(
        key: _editFormKey,
        autovalidate: true,
        // readonly: true,
        child: Column(
          children: <Widget>[
            FormBuilderTextField(
                attribute: 'name',
                maxLength: 40,
                decoration: InputDecoration(labelText: 'Name'),
                initialValue: _interventions[index].name),
            FormBuilderTextField(
                attribute: 'description',
                decoration: InputDecoration(labelText: 'Description'),
                initialValue: _interventions[index].description),
            MaterialButton(
              color: Theme.of(context).accentColor,
              onPressed: () {
                _editFormKey.currentState.save();
                if (_editFormKey.currentState.validate()) {
                  setState(() {
                    _interventions[index].name = _editFormKey.currentState.value['name'];
                    _interventions[index].description = _editFormKey.currentState.value['description'];
                  });
                  print('saved');
                  Navigator.pop(context);
                  // TODO: show dialog "saved"
                } else {
                  print('validation failed');
                }
              },
              child: Text(
                'Save',
                style: TextStyle(color: Colors.white),
              ),
            )
          ],
        ),
      ),
    );
  }

  void _showEditTaskDialog(interventionIndex, index) {
    showDialog(
        context: context,
        builder: (context) {
          return _buildEditTaskDialog(context, interventionIndex, index);
        });
  }

  Widget _buildEditTaskDialog(context, interventionIndex, index) {
    return AlertDialog(
      content: FormBuilder(
        key: _editFormKey,
        autovalidate: true,
        // readonly: true,
        child: Column(
          children: <Widget>[
            FormBuilderTextField(
                attribute: 'name',
                maxLength: 40,
                decoration: InputDecoration(labelText: 'Name'),
                initialValue: _interventions[interventionIndex].tasks[index].name),
            FormBuilderTextField(
                attribute: 'description',
                decoration: InputDecoration(labelText: 'Description'),
                initialValue: _interventions[interventionIndex].tasks[index].description),
            MaterialButton(
              color: Theme.of(context).accentColor,
              onPressed: () {
                _editFormKey.currentState.save();
                if (_editFormKey.currentState.validate()) {
                  setState(() {
                    _interventions[interventionIndex].tasks[index].name = _editFormKey.currentState.value['name'];
                    _interventions[interventionIndex].tasks[index].description =
                        _editFormKey.currentState.value['description'];
                  });
                  print('saved');
                  Navigator.pop(context);
                  // TODO: show dialog "saved"
                } else {
                  print('validation failed');
                }
              },
              child: Text(
                'Save',
                style: TextStyle(color: Colors.white),
              ),
            )
          ],
        ),
      ),
    );
  }
}
