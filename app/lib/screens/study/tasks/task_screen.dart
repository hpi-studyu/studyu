import 'package:flutter/material.dart';
import 'package:studyu_core/core.dart';

import 'intervention/checkmark_task_widget.dart';
import 'observation/questionnaire_task_widget.dart';

class TaskScreen extends StatefulWidget {
  final TaskInstance taskInstance;

  static MaterialPageRoute<bool> routeFor({@required TaskInstance taskInstance}) => MaterialPageRoute(
        builder: (_) => TaskScreen(taskInstance: taskInstance),
      );

  const TaskScreen({@required this.taskInstance, Key key}) : super(key: key);

  @override
  State<TaskScreen> createState() => _TaskScreenState();
}

class _TaskScreenState extends State<TaskScreen> {
  Widget _buildTask() {
    switch (widget.taskInstance.task.runtimeType) {
      case CheckmarkTask:
        return CheckmarkTaskWidget(
          task: widget.taskInstance.task as CheckmarkTask,
          key: UniqueKey(),
          completionPeriod: widget.taskInstance.completionPeriod,
        );
      case QuestionnaireTask:
        return QuestionnaireTaskWidget(
          task: widget.taskInstance.task as QuestionnaireTask,
          key: UniqueKey(),
          completionPeriod: widget.taskInstance.completionPeriod,
        );
      default:
        print('${widget.taskInstance.task.runtimeType} is not a supported Task!');
        return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.taskInstance.task.title ?? ''),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(widget.taskInstance.task.title ?? '', style: theme.textTheme.headlineMedium.copyWith(fontSize: 24)),
              const SizedBox(height: 20),
              _buildTask(),
            ],
          ),
        ),
      ),
    );
  }
}
