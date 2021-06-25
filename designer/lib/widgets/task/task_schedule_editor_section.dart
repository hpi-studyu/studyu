import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:studyu_core/core.dart';

import '../../widgets/task/reminder_editor.dart';

class TaskScheduleEditorSection extends StatefulWidget {
  final Task task;

  const TaskScheduleEditorSection({@required this.task, Key key}) : super(key: key);

  @override
  _TaskScheduleEditorSectionState createState() => _TaskScheduleEditorSectionState();
}

class _TaskScheduleEditorSectionState extends State<TaskScheduleEditorSection> {
  bool _lockingTimesEnabled = true;

  void _addReminder() {
    final reminder = StudyUTimeOfDay(hour: 0, minute: 0);
    setState(() {
      widget.task.schedule.reminders.add(reminder);
    });
  }

  void _removeReminder(int index) {
    setState(() {
      widget.task.schedule.reminders.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Scheduling',
          style: Theme.of(context).textTheme.headline6,
        ),
        Text('Remind participant at'),
        ListView.builder(
          physics: const NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          itemCount: widget.task.schedule.reminders.length,
          itemBuilder: (buildContext, index) {
            return ReminderEditor(
                key: UniqueKey(),
                reminder: widget.task.schedule.reminders[index],
                remove: () => _removeReminder(index));
          },
        ),
        ElevatedButton.icon(
          style: ElevatedButton.styleFrom(primary: Colors.green),
          icon: Icon(Icons.add),
          onPressed: _addReminder,
          label: Text('Add reminder time'),
        ),
      ],
    );
  }
}
