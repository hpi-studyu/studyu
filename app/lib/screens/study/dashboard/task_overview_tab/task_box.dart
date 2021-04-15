import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:studyou_core/core.dart';

import '../../../../models/app_state.dart';
import '../../../../widgets/round_checkbox.dart';
import '../../tasks/task_screen.dart';

class TaskBox extends StatefulWidget {
  final Task task;
  final Icon icon;
  final Function() onCompleted;

  const TaskBox({@required this.task, @required this.icon, @required this.onCompleted});

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
    final completed = context.watch<AppState>().activeStudy.isTaskFinishedFor(widget.task.id, DateTime.now());
    return Card(
      elevation: 2,
      child: InkWell(
        onTap: _navigateToTaskScreen,
        child: Row(
          children: [
            Expanded(
              child: ListTile(
                leading: widget.icon,
                title: Text(widget.task.title),
              ),
            ),
            RoundCheckbox(
              value: completed, //_isCompleted,
              onChanged: (value) => _navigateToTaskScreen(),
            )
          ],
        ),
      ),
    );
  }
}
