import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:provider/provider.dart';
import 'package:studyou_core/models/models.dart';

import '../../../../models/app_state.dart';
import '../../../../widgets/round_checkbox.dart';
import '../../tasks/task_screen.dart';

class TaskBox extends StatefulWidget {
  final Task task;

  const TaskBox({@required this.task});

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
                leading: Icon(MdiIcons.orderBoolAscendingVariant),
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
