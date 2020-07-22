import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:provider/provider.dart';
import 'package:study_designer/designer/interventions_designer/schedule_card.dart';
import 'package:study_designer/models/designer_state.dart';

class TaskCard extends StatefulWidget {
  final int interventionIndex;
  final int taskIndex;
  final void Function(int taskIndex) removeTask;

  const TaskCard({@required this.interventionIndex, @required this.taskIndex, @required this.removeTask, Key key})
      : super(key: key);

  @override
  _TaskCardState createState() => _TaskCardState();
}

class _TaskCardState extends State<TaskCard> {
  LocalTask task;

  final GlobalKey<FormBuilderState> _editFormKey = GlobalKey<FormBuilderState>();

  void _addFixedSchedule() {
    setState(() {
      final schedule = LocalFixedSchedule()
        ..hour = 0
        ..minute = 0;
      task.schedules.add(schedule);
    });
  }

  void _removeSchedule(scheduleIndex) {
    setState(() {
      task.schedules.removeAt(scheduleIndex);
    });
  }

  @override
  Widget build(BuildContext context) {
    task = context
        .watch<DesignerModel>()
        .draftStudy
        .studyDetails
        .interventions[widget.interventionIndex]
        .tasks[widget.taskIndex];

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
                    showDialog(context: context, builder: _buildEditDialog);
                  },
                  child: const Text('Edit'),
                ),
                FlatButton(
                  onPressed: () {
                    widget.removeTask(widget.taskIndex);
                  },
                  child: const Text('Delete'),
                ),
              ],
            ),
            ListTile(
              title: Text(task.name.isEmpty ? 'Name' : task.name),
              subtitle: Text(task.description.isEmpty ? 'Description' : task.description),
            ),
            ...task.schedules.asMap().entries.map((entry) => ScheduleCard()).toList(),
            ButtonBar(
              children: <Widget>[
                FlatButton(
                  onPressed: _addFixedSchedule,
                  child: const Text('Add fixed schedule'),
                ),
              ],
            ),
          ],
        )));
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
                initialValue: task.name),
            FormBuilderTextField(
                attribute: 'description',
                decoration: InputDecoration(labelText: 'Description'),
                initialValue: task.description),
            MaterialButton(
              color: Theme.of(context).accentColor,
              onPressed: () {
                _editFormKey.currentState.save();
                if (_editFormKey.currentState.validate()) {
                  setState(() {
                    task.name = _editFormKey.currentState.value['name']
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
