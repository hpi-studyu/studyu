import 'package:flutter/material.dart';
import 'package:studyu_core/core.dart';

import '../../widgets/task/fixed_schedule_editor.dart';

class TaskScheduleEditorSection extends StatefulWidget {
  final Task task;

  const TaskScheduleEditorSection({@required this.task, Key key}) : super(key: key);

  @override
  _TaskScheduleEditorSectionState createState() => _TaskScheduleEditorSectionState();
}

class _TaskScheduleEditorSectionState extends State<TaskScheduleEditorSection> {
  void _add() {
    final time = ScheduleTime(hour: 0, minute: 0);
    final schedule = FixedSchedule()..time = time;
    setState(() {
      widget.task.schedule.add(schedule);
    });
  }

  void _remove(int index) {
    setState(() {
      widget.task.schedule.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Divider(),
      Text('Schedule'),
      ListView.builder(
        physics: const NeverScrollableScrollPhysics(),
        shrinkWrap: true,
        itemCount: widget.task.schedule.length,
        itemBuilder: (buildContext, index) {
          return FixedScheduleEditor(
              key: UniqueKey(), schedule: widget.task.schedule[index] as FixedSchedule, remove: () => _remove(index));
        },
      ),
      Row(children: [Spacer(), IconButton(icon: Icon(Icons.add), onPressed: _add), Spacer()])
    ]);
  }
}
