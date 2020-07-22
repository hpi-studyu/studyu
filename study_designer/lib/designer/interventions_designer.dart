import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:provider/provider.dart';
import 'package:studyou_core/models/models.dart';

import '../models/designer_state.dart';

class InterventionsDesigner extends StatefulWidget {
  @override
  _InterventionsDesignerState createState() => _InterventionsDesignerState();
}

const String keyInterventionName = 'intervention_name_';
const String keyInterventionDescription = 'intervention_description_';

class _InterventionsDesignerState extends State<InterventionsDesigner> {
  Study _draftStudy;

  List<LocalIntervention> interventions = [];

  final GlobalKey<FormBuilderState> _editFormKey = GlobalKey<FormBuilderState>();

  void _addIntervention() {
    setState(() {
      final index = interventions.length;
      final intervention = LocalIntervention()
        ..name = ''
        ..description = ''
        ..tasks = [];
      interventions.add(intervention);
    });
  }

  void _removeIntervention(index) {
    setState(() {
      interventions.removeAt(index);
    });
  }

  void _addCheckMarkTask(index) {
    setState(() {
      final task = LocalCheckMarkTask()
        ..name = ''
        ..description = '';
      interventions[index].tasks.add(task);
    });
    print(interventions[index].tasks);
  }

  void _removeTask(interventionIndex, taskIndex) {
    setState(() {
      interventions[interventionIndex].tasks.removeAt(taskIndex);
    });
  }

  @override
  Widget build(BuildContext context) {
    _draftStudy = context.watch<DesignerModel>().draftStudy;
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.all(16),
      child: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            ...interventions.asMap().entries.map((entry) => _buildInterventionCard(entry.key, entry.value)).toList(),
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
          ],
        )));
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
                initialValue: interventions[index].name),
            FormBuilderTextField(
                attribute: 'description',
                decoration: InputDecoration(labelText: 'Description'),
                initialValue: interventions[index].description),
            MaterialButton(
              color: Theme.of(context).accentColor,
              onPressed: () {
                _editFormKey.currentState.save();
                if (_editFormKey.currentState.validate()) {
                  setState(() {
                    interventions[index].name = _editFormKey.currentState.value['name'];
                    interventions[index].description = _editFormKey.currentState.value['description'];
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
                initialValue: interventions[interventionIndex].tasks[index].name),
            FormBuilderTextField(
                attribute: 'description',
                decoration: InputDecoration(labelText: 'Description'),
                initialValue: interventions[interventionIndex].tasks[index].description),
            MaterialButton(
              color: Theme.of(context).accentColor,
              onPressed: () {
                _editFormKey.currentState.save();
                if (_editFormKey.currentState.validate()) {
                  setState(() {
                    interventions[interventionIndex].tasks[index].name = _editFormKey.currentState.value['name'];
                    interventions[interventionIndex].tasks[index].description =
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

class LocalIntervention {
  String name;
  String description;
  List<LocalTask> tasks;
}

class LocalTask {
  String name;
  String description;
}

class LocalCheckMarkTask extends LocalTask {}
