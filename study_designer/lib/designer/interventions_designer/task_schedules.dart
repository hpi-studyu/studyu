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
    return Column(children: [
      ListView.builder(
        shrinkWrap: true,
        itemCount: widget.task.schedule.length + 1,
        itemBuilder: (buildContext, index) {
          return index == widget.task.schedule.length
              ? Row(children: [
                  Spacer(),
                  RaisedButton.icon(
                      onPressed: _add, icon: Icon(Icons.add), color: Colors.green, label: Text('Add Schedule')),
                  Spacer()
                ])
              : FixedScheduleWidget(
                  key: UniqueKey(), schedule: widget.task.schedule[index], remove: () => _remove(index));
        },
      )
    ]);
  }
}
