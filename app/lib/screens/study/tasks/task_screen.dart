import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:studyou_core/models/models.dart';

import '../../../models/app_state.dart';
import 'intervention/checkmark_task_widget.dart';
import 'observation/questionnaire_task_widget.dart';

class TaskScreen extends StatefulWidget {
  final Task task;
  final String taskId;

  const TaskScreen({@required this.task, this.taskId, Key key}) : super(key: key);

  @override
  _TaskScreenState createState() => _TaskScreenState();
}

class _TaskScreenState extends State<TaskScreen> {
  Task task;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (widget.task != null) {
      task = widget.task;
    } else if (widget.taskId != null) {
      final study = context.read<AppState>().activeStudy;
      final tasks = <Task>[
        ...study.observations.where((observation) => observation.id == widget.taskId).toList(),
        ...study.interventionSet.interventions
            .map((intervention) => intervention.tasks.where((task) => task.id == widget.taskId))
            .expand((task) => task)
            .toList()
      ];
      if (tasks.isEmpty) {
        print('No task found with ID ${widget.taskId}');
      } else if (tasks.length > 1) {
        print('Too many tasks found with ID ${widget.taskId}');
      } else {
        task = tasks.first;
      }
    }
    if (task == null) {
      Navigator.of(context).pop();
    }
  }

  Widget _buildTask() {
    switch (widget.task.runtimeType) {
      case CheckmarkTask:
        return CheckmarkTaskWidget(task: widget.task);
      case QuestionnaireTask:
        return QuestionnaireTaskWidget(task: widget.task);
      default:
        print('${widget.task.runtimeType} is not a supported Task!');
        return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.task.title),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Center(
            child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(widget.task.title, style: theme.textTheme.headline4.copyWith(fontSize: 24)),
            SizedBox(height: 20),
            _buildTask(),
          ],
        )),
      ),
    );
  }
}
