import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:studyu_app/routes.dart';
import 'package:studyu_core/core.dart';

import '../../../../models/app_state.dart';
import '../../../../theme.dart';
import '../../../../widgets/round_checkbox.dart';
import '../../tasks/task_screen.dart';

class TaskBox extends StatefulWidget {
  final TaskInstance taskInstance;
  final Icon icon;
  final Function() onCompleted;

  const TaskBox({
    Key key,
    @required this.taskInstance,
    @required this.icon,
    @required this.onCompleted,
  }) : super(key: key);

  @override
  State<TaskBox> createState() => _TaskBoxState();
}

class _TaskBoxState extends State<TaskBox> {
  Future<void> _navigateToTaskScreen() async {
    await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (context) => TaskScreen(taskInstance: widget.taskInstance)),
    );
    widget.onCompleted();
    // Rebuild widget
    setState(() {});
    // if (mounted) scheduleNotifications(context);
    // todo nur loading screen zeigen, wenn study phase abgeschlossen wurde, damit dashboard neu lädt
    Navigator.pushNamedAndRemoveUntil(context, Routes.loading, (_) => false);
  }

  @override
  Widget build(BuildContext context) {
    final completed = context
        .watch<AppState>()
        .activeSubject
        .completedTaskInstanceForDay(widget.taskInstance.task.id, widget.taskInstance.completionPeriod, DateTime.now());
    return Card(
      elevation: 2,
      child: InkWell(
        onTap: (completed ||
                    !context.read<AppState>().isPreview ||
                    !widget.taskInstance.completionPeriod.contains(StudyUTimeOfDay.now())) &&
                !kDebugMode
            ? () {}
            : _navigateToTaskScreen,
        child: Row(
          children: [
            Expanded(
              child: ListTile(
                leading: widget.icon,
                title: Text(widget.taskInstance.task.title ?? ''),
                onTap: completed ? null : () => _navigateToTaskScreen(),
              ),
            ),
            if (widget.taskInstance.completionPeriod.contains(StudyUTimeOfDay.now()) ||
                context.read<AppState>().isPreview ||
                completed)
              RoundCheckbox(
                value: completed, //_isCompleted,
                onChanged: (value) => completed ? {} : _navigateToTaskScreen(),
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
