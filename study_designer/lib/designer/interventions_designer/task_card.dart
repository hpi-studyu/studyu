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
  final void Function(int taskIndex) remove;
  final void Function(int interventionIndex) onTap;

  const TaskCard(
      {@required this.interventionIndex,
      @required this.taskIndex,
      @required this.remove,
      @required this.isEditing,
      @required this.onTap,
      Key key})
      : super(key: key);

  @override
  _TaskCardState createState() => _TaskCardState();
}

class _TaskCardState extends State<TaskCard> {
  LocalTask task;
  int selectedScheduleIndex;

  final GlobalKey<FormBuilderState> _editFormKey = GlobalKey<FormBuilderState>();

  void _addFixedSchedule() {
    setState(() {
      final schedule = LocalFixedSchedule()
        ..hour = 0
        ..minute = 0;
      task.schedules.add(schedule);
      selectedScheduleIndex = task.schedules.length - 1;
    });
  }

  void _removeSchedule(scheduleIndex) {
    setState(() {
      selectedScheduleIndex = null;
      task.schedules.removeAt(scheduleIndex);
    });
  }

  void _selectSchedule(index) {
    setState(() {
      selectedScheduleIndex = index;
    });
    widget.onTap(widget.taskIndex);
  }

  @override
  Widget build(BuildContext context) {
    task = context
        .watch<DesignerModel>()
        .draftStudy
        .studyDetails
        .interventions[widget.interventionIndex]
        .tasks[widget.taskIndex];

    final cardContent = <Widget>[];
    cardContent.add(Text(widget.isEditing.toString()));
    cardContent.add(Text('Task ${(widget.taskIndex + 1).toString()}'));
    if (widget.isEditing) {
      cardContent.add(_buildDeleteButton());
    }
    if (widget.isEditing && selectedScheduleIndex == null) {
      cardContent.add(_buildEditMetaDataForm());
    } else {
      cardContent.add(_buildShowMetaData());
    }
    cardContent.addAll(_buildScheduleCards());
    if (widget.isEditing) {
      cardContent.add(_buildCardFooter());
    }

    return GestureDetector(
        onTap: () {
          setState(() => selectedScheduleIndex = null);
          widget.onTap(widget.taskIndex);
        },
        child: Container(
            margin: EdgeInsets.all(10.0),
            decoration: BoxDecoration(border: Border.all()),
            child: Column(children: cardContent)));
  }

  Widget _buildDeleteButton() {
    return ButtonBar(
      children: <Widget>[
        FlatButton(
          onPressed: () {
            widget.remove(widget.taskIndex);
          },
          child: const Text('Delete'),
        ),
      ],
    );
  }

  List<Widget> _buildScheduleCards() {
    return task.schedules
        .asMap()
        .entries
        .map((entry) => ScheduleCard(
            interventionIndex: widget.interventionIndex,
            taskIndex: widget.taskIndex,
            scheduleIndex: entry.key,
            remove: _removeSchedule,
            isEditing: widget.isEditing && entry.key == selectedScheduleIndex,
            onTap: _selectSchedule))
        .toList();
  }

  Widget _buildEditMetaDataForm() {
    return FormBuilder(
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
    );
  }

  void saveFormChanges() {
    _editFormKey.currentState.save();
    if (_editFormKey.currentState.validate()) {
      setState(() {
        task.name = _editFormKey.currentState.value['name'];
        task.description = _editFormKey.currentState.value['description'];
      });
    }
  }

  Widget _buildShowMetaData() {
    return ListTile(
      title: Text(task.name.isEmpty ? 'Name' : task.name),
      subtitle: Text(task.description.isEmpty ? 'Description' : task.description),
    );
  }

  Widget _buildCardFooter() {
    return ButtonBar(
      children: <Widget>[
        FlatButton(
          onPressed: _addFixedSchedule,
          child: const Text('Add fixed schedule'),
        ),
      ],
    );
  }
}
