import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:studyu_core/core.dart';

import '../../../../models/app_state.dart';
import '../../../../theme.dart';
import '../../../../widgets/round_checkbox.dart';
import '../../tasks/task_screen.dart';

class TaskBox extends StatefulWidget {
  final TimedTask timedTask;
  final Icon icon;
  final Function() onCompleted;

  const TaskBox({
    @required this.timedTask,
    @required this.icon,
    @required this.onCompleted,
  });

  @override
  State<TaskBox> createState() => _TaskBoxState();
}

class _TaskBoxState extends State<TaskBox> {
  Future<void> _navigateToTaskScreen() async {
    await Navigator.push<bool>(
        context, MaterialPageRoute(builder: (context) => TaskScreen(timedTask: widget.timedTask)));
    widget.onCompleted();
    // Rebuild widget
    setState(() {});
  }

  Widget drawCheckbox({bool completed}) {
    return RoundCheckbox(
      value: completed,
      onChanged: (value) => completed ? () {} : _navigateToTaskScreen(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final completed = context
        .watch<AppState>()
        .activeSubject
        .isTimedTaskFinished(widget.timedTask.task.id, widget.timedTask.completionPeriod, DateTime.now());
    return Card(
      elevation: 2,
      child: InkWell(
        onTap: (completed || !widget.timedTask.completionPeriod.contains(StudyUTimeOfDay.now())) && !kDebugMode
            ? () {}
            : _navigateToTaskScreen,
        child: Row(
          children: [
            Expanded(
              child: ListTile(
                leading: widget.icon,
                title: Text(widget.timedTask.task.title ?? ''),
              ),
            ),
            if (widget.timedTask.completionPeriod.contains(StudyUTimeOfDay.now()) || completed)
              drawCheckbox(completed: completed)
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
