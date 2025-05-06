import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:studyu_app/models/app_state.dart';
import 'package:studyu_app/screens/study/tasks/task_screen.dart';
import 'package:studyu_app/theme.dart';
import 'package:studyu_app/util/schedule_notifications.dart';
import 'package:studyu_app/widgets/round_checkbox.dart';
import 'package:studyu_core/core.dart';

class TaskBox extends StatefulWidget {
  final TaskInstance taskInstance;
  final Icon icon;
  final Function() onCompleted;

  const TaskBox({
    super.key,
    required this.taskInstance,
    required this.icon,
    required this.onCompleted,
  });

  @override
  State<TaskBox> createState() => _TaskBoxState();
}

class _TaskBoxState extends State<TaskBox> {
  bool _showDebug = true;

  Future<void> _navigateToTaskScreen() async {
    await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (context) => TaskScreen(taskInstance: widget.taskInstance),
      ),
    );
    widget.onCompleted();
    // Rebuild widget
    setState(() {});
    if (mounted) scheduleNotifications(context);
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final completed =
        context.watch<AppState>().activeSubject!.completedTaskInstanceForDay(
              widget.taskInstance.task.id,
              widget.taskInstance.completionPeriod,
              now,
            );
    final completedTasks = context
        .watch<AppState>()
        .activeSubject!
        .getTaskProgressForDay(widget.taskInstance.task.id, DateTime.now());
    final isPreview = context.read<AppState>().isPreview;
    final isInsidePeriod =
        widget.taskInstance.completionPeriod.contains(StudyUTimeOfDay.now());

    final isTaskOpen = !completed && isInsidePeriod || isPreview || kDebugMode;

    return Card(
      elevation: 2,
      child: Column(
        children: [
          InkWell(
            onTap: isTaskOpen ? _navigateToTaskScreen : () {},
            onLongPress: kDebugMode
                ? () {
                    setState(() {
                      _showDebug = !_showDebug;
                    });
                  }
                : null,
            child: Row(
              children: [
                Expanded(
                  child: ListTile(
                    leading: widget.icon,
                    title: Text(widget.taskInstance.task.title ?? ''),
                    onTap: isTaskOpen ? _navigateToTaskScreen : () {},
                  ),
                ),
                if (isInsidePeriod || isPreview || completed)
                  RoundCheckbox(
                    value: completed,
                    onChanged: (value) =>
                        isTaskOpen ? _navigateToTaskScreen() : () {},
                  )
                else
                  Padding(
                    padding: const EdgeInsets.fromLTRB(0, 0, 8, 0),
                    child: Icon(Icons.lock, color: theme.colorScheme.secondary),
                  ),
              ],
            ),
          ),
          if (_showDebug)
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('🧪 DEBUG INFO',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  Text('Now local: $now'),
                  Text('Now UTC: ${now.toUtc()}'),
                  Text('isInsidePeriod: $isInsidePeriod'),
                  Text('Completed: $completed'),
                  Text(
                      'Unlocks: ${widget.taskInstance.completionPeriod.unlockTime}'),
                  Text(
                      'Locks: ${widget.taskInstance.completionPeriod.lockTime}'),
                  Text('Task ID: ${widget.taskInstance.task.id}'),
                  Text('Period ID: ${widget.taskInstance.completionPeriod.id}'),
                  Text('Completed tasks: $completedTasks'),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
