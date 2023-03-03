import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:studyu_app/models/app_state.dart';
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
  TaskInstance taskInstance;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final subject = context.watch<AppState>().activeSubject;
    taskInstance = TaskInstance.fromInstanceId(widget.taskInstance.id, study: subject.study);
  }

  Widget _buildTask() {
    switch (taskInstance.task.runtimeType) {
      case CheckmarkTask:
        return CheckmarkTaskWidget(
          task: taskInstance.task as CheckmarkTask,
          key: UniqueKey(),
          completionPeriod: taskInstance.completionPeriod,
        );
      case QuestionnaireTask:
        return QuestionnaireTaskWidget(
          task: taskInstance.task as QuestionnaireTask,
          key: UniqueKey(),
          completionPeriod: taskInstance.completionPeriod,
        );
      default:
        print('${taskInstance.task.runtimeType} is not a supported Task!');
        return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(taskInstance.task.title ?? ''),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(taskInstance.task.title ?? '', style: theme.textTheme.headlineMedium.copyWith(fontSize: 24)),
              const SizedBox(height: 20),
              _buildTask(),
            ],
          ),
        ),
      ),
    );
  }
}
