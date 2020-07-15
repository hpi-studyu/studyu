import 'package:flutter/material.dart';
import 'package:studyou_core/models/models.dart';

import 'intervention/checkmark_task_widget.dart';
import 'observation/questionnaire_task_widget.dart';

class TaskScreen extends StatefulWidget {
  final Task task;

  const TaskScreen({@required this.task, Key key}) : super(key: key);

  @override
  _TaskScreenState createState() => _TaskScreenState();
}

class _TaskScreenState extends State<TaskScreen> {
  Widget _buildTask() {
    switch (widget.task.runtimeType) {
      case CheckmarkTask:
        return CheckmarkTaskWidget();
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
