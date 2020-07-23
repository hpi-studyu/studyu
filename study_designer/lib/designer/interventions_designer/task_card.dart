import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:provider/provider.dart';
import 'package:study_designer/designer/interventions_designer/schedule_card.dart';
import 'package:study_designer/models/designer_state.dart';

class TaskCard extends StatefulWidget {
  final int interventionIndex;
  final int taskIndex;
  final bool isEditing;
  final void Function(int taskIndex) removeTask;
  final void Function(int interventionIndex) onTap;

  const TaskCard(
      {@required this.interventionIndex,
      @required this.taskIndex,
      @required this.removeTask,
      @required this.isEditing,
      @required this.onTap,
      Key key})
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
        decoration: BoxDecoration(border: Border.all()),
        child: widget.isEditing ? _buildEditWidget(context) : _buildShowWidget(context));
  }

  Widget _buildShowWidget(context) {
    return GestureDetector(
      onTap: () {
        widget.onTap(widget.taskIndex);
      },
      child: Column(
        children: [
          Text('Checkmark Task'),
          ListTile(
            title: Text(task.name.isEmpty ? 'Name' : task.name),
            subtitle: Text(task.description.isEmpty ? 'Description' : task.description),
          ),
          ...task.schedules.asMap().entries.map((entry) => ScheduleCard()).toList(),
        ],
      ),
    );
  }

  void saveFormChanges() {
    _editFormKey.currentState.save();
    if (_editFormKey.currentState.validate()) {
      setState(() {
        task.name = _editFormKey.currentState.value['name'];
        task.description = _editFormKey.currentState.value['description'];
      });
      print('saved');
    } else {
      print('validation failed');
    }
  }

  Widget _buildEditWidget(context) {
    return Column(
      children: [
        Text('Checkmark Task'),
        ButtonBar(
          children: <Widget>[
            FlatButton(
              onPressed: () {
                widget.removeTask(widget.taskIndex);
              },
              child: const Text('Delete'),
            ),
          ],
        ),
        FormBuilder(
          key: _editFormKey,
          autovalidate: true,
          // readonly: true,
          child: Column(
            children: <Widget>[
              FormBuilderTextField(
                  onChanged: (value) {
                    saveFormChanges();
                  },
                  attribute: 'name',
                  maxLength: 40,
                  decoration: InputDecoration(labelText: 'Name'),
                  initialValue: task.name),
              FormBuilderTextField(
                  onChanged: (value) {
                    saveFormChanges();
                  },
                  attribute: 'description',
                  decoration: InputDecoration(labelText: 'Description'),
                  initialValue: task.description),
            ],
          ),
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
    );
  }
}
