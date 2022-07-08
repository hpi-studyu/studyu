import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:studyu_core/core.dart';

import '../../../../models/app_state.dart';
import '../../../../theme.dart';
import '../../../../widgets/round_checkbox.dart';
import '../../tasks/task_screen.dart';

class TaskBox extends StatefulWidget {
  final Task task;
  final CompletionPeriod completionPeriod;
  final Icon icon;
  final Function() onCompleted;

  const TaskBox({
    @required this.task,
    @required this.completionPeriod,
    @required this.icon,
    @required this.onCompleted,
  });

  @override
  State<TaskBox> createState() => _TaskBoxState();
}

class _TaskBoxState extends State<TaskBox> {
  Future<void> _navigateToTaskScreen() async {
    await Navigator.push<bool>(context, MaterialPageRoute(builder: (context) => TaskScreen(task: widget.task)));
    widget.onCompleted();
    // Rebuild widget
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final completed = context.watch<AppState>().activeSubject.isTaskFinishedFor(widget.task.id, DateTime.now());
    final now = DateTime.now();
    final nowTime = StudyUTimeOfDay(hour: now.hour, minute: now.minute);

    return Card(
      elevation: 2,
      child: InkWell(
        onTap: completed || !widget.completionPeriod.contains(nowTime) ? () {} : _navigateToTaskScreen,
        child: Row(
          children: [
            Expanded(
              child: ListTile(
                leading: widget.icon,
                title: Text(widget.task.title),
              ),
            ),
            if (widget.completionPeriod.contains(nowTime))
              RoundCheckbox(
                value: completed, //_isCompleted,
                onChanged: (value) => completed ? () {} : _navigateToTaskScreen(),
              )
            else
              Padding(
                padding: const EdgeInsets.fromLTRB(0, 0, 8, 0),
                child: Icon(Icons.lock, color: theme.colorScheme.secondary),
              )
          ],
        ),
      ),
    );
  }
}
