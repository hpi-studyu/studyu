import 'package:flutter/material.dart';
import 'package:studyu_core/core.dart';

import 'intervention/checkmark_task_widget.dart';
import 'observation/questionnaire_task_widget.dart';

class TaskScreen extends StatefulWidget {
  final TimedTask timedTask;

  const TaskScreen({@required this.timedTask, Key key}) : super(key: key);

  @override
  _TaskScreenState createState() => _TaskScreenState();
}

class _TaskScreenState extends State<TaskScreen> {
  Widget _buildTask() {
    switch (widget.timedTask.task.runtimeType) {
      case CheckmarkTask:
        return CheckmarkTaskWidget(
          task: widget.timedTask.task as CheckmarkTask,
          completionPeriod: widget.timedTask.completionPeriod,
        );
      case QuestionnaireTask:
        return QuestionnaireTaskWidget(
          task: widget.timedTask.task as QuestionnaireTask,
          completionPeriod: widget.timedTask.completionPeriod,
        );
      default:
        print('${widget.timedTask.task.runtimeType} is not a supported Task!');
        return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.timedTask.task.title ?? ''),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(widget.timedTask.task.title ?? '', style: theme.textTheme.headlineMedium.copyWith(fontSize: 24)),
              const SizedBox(height: 20),
              _buildTask(),
            ],
          ),
        ),
      ),
    );
  }
}
