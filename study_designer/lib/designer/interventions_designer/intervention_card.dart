import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:provider/provider.dart';
import 'package:study_designer/designer/interventions_designer/task_card.dart';
import 'package:study_designer/models/designer_state.dart';

class InterventionCard extends StatefulWidget {
  final int interventionIndex;
  final void Function(int interventionIndex) removeIntervention;

  const InterventionCard({@required this.interventionIndex, @required this.removeIntervention, Key key})
      : super(key: key);

  @override
  _InterventionCardState createState() => _InterventionCardState();
}

class _InterventionCardState extends State<InterventionCard> {
  LocalIntervention intervention;

  final GlobalKey<FormBuilderState> _editFormKey = GlobalKey<FormBuilderState>();

  void _addCheckMarkTask() {
    setState(() {
      final task = LocalCheckMarkTask()
        ..name = ''
        ..description = ''
        ..schedules = [];
      intervention.tasks.add(task);
    });
  }

  void _removeTask(taskIndex) {
    setState(() {
      intervention.tasks.removeAt(taskIndex);
    });
  }

  @override
  Widget build(BuildContext context) {
    intervention = context.watch<DesignerModel>().draftStudy.studyDetails.interventions[widget.interventionIndex];

    return Container(
      margin: EdgeInsets.all(10.0),
      child: Card(
        child: Column(children: [
          ButtonBar(
            children: <Widget>[
              FlatButton(
                onPressed: _showEditInterventionDialog,
                child: const Text('Edit'),
              ),
              FlatButton(
                onPressed: () {
                  widget.removeIntervention(widget.interventionIndex);
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
          ...intervention.tasks
              .asMap()
              .entries
              .map((entry) =>
                  TaskCard(interventionIndex: widget.interventionIndex, taskIndex: entry.key, removeTask: _removeTask))
              .toList(),
          ButtonBar(
            children: <Widget>[
              FlatButton(
                onPressed: _addCheckMarkTask,
                child: const Text('Add checkmark task'),
              ),
            ],
          ),
        ]),
      ),
    );
  }

  void _showEditInterventionDialog() {
    showDialog(context: context, builder: _buildEditDialog);
  }

  Widget _buildEditDialog(context) {
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
                initialValue: intervention.name),
            FormBuilderTextField(
                attribute: 'description',
                decoration: InputDecoration(labelText: 'Description'),
                initialValue: intervention.description),
            MaterialButton(
              color: Theme.of(context).accentColor,
              onPressed: () {
                _editFormKey.currentState.save();
                if (_editFormKey.currentState.validate()) {
                  setState(() {
                    intervention.name = _editFormKey.currentState.value['name']
                      ..description = _editFormKey.currentState.value['description'];
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
