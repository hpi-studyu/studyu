import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:studyou_core/models/models.dart';

import '../../../../models/app_state.dart';
import '../../../../widgets/round_checkbox.dart';
import '../../tasks/task_screen.dart';

class TaskBox extends StatefulWidget {
  final Task task;
  final Icon icon;

  const TaskBox({@required this.task, this.icon});

  @override
  State<TaskBox> createState() => _TaskBoxState();
}

class _TaskBoxState extends State<TaskBox> {
  bool _isCompleted = false;

  Future<void> _navigateToTaskScreen() async {
    final completed =
        await Navigator.push<bool>(context, MaterialPageRoute(builder: (context) => TaskScreen(task: widget.task)));
    setState(() {
      _isCompleted = completed;
    });
  }

  @override
  Widget build(BuildContext context) {
    _isCompleted = context.watch<AppModel>().activeStudy.isTaskFinishedFor(widget.task.id, DateTime.now());
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
              value: _isCompleted,
              onChanged: (value) => _navigateToTaskScreen(),
            )
          ],
        ),
      ),
    );
  }
}
