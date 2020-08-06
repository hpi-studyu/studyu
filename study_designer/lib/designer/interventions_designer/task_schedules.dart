import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:study_designer/widgets/fixed_schedule_widget.dart';
import 'package:studyou_core/models/models.dart';

class TaskSchedules extends StatefulWidget {
  final Task task;

  const TaskSchedules({@required this.task, Key key}) : super(key: key);

  @override
  _TaskSchedulesState createState() => _TaskSchedulesState();
}

class _TaskSchedulesState extends State<TaskSchedules> {
  void _add() {
    final time = Time()
      ..hour = 0
      ..minute = 0;
    final schedule = FixedSchedule()..time = time;
    setState(() {
      widget.task.schedule.add(schedule);
    });
  }

  void _remove(index) {
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
          return FixedScheduleWidget(
              key: UniqueKey(), schedule: widget.task.schedule[index], remove: () => _remove(index));
        },
      ),
      Row(children: [Spacer(), IconButton(icon: Icon(Icons.add), onPressed: _add), Spacer()])
    ]);
  }
}
