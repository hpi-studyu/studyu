import 'dart:io';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:studyu_app/models/app_state.dart';
import 'package:studyu_app/util/cache.dart';
import 'package:studyu_app/widgets/html_text.dart';
import 'package:studyu_core/core.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'intervention/checkmark_task_widget.dart';
import 'observation/questionnaire_task_widget.dart';

class TaskScreen extends StatefulWidget {
  final TaskInstance taskInstance;

  static MaterialPageRoute<bool> routeFor({required TaskInstance taskInstance}) => MaterialPageRoute(
        builder: (_) => TaskScreen(taskInstance: taskInstance),
      );

  const TaskScreen({required this.taskInstance, super.key});

  @override
  State<TaskScreen> createState() => _TaskScreenState();
}

class _TaskScreenState extends State<TaskScreen> {
  late TaskInstance taskInstance;
  StudySubject? subject;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    subject = context.watch<AppState>().activeSubject;
    taskInstance = TaskInstance.fromInstanceId(widget.taskInstance.id, study: subject!.study);
  }

  Widget? _buildTask() {
    switch (taskInstance.task.runtimeType) {
      case CheckmarkTask _:
        return CheckmarkTaskWidget(
          task: taskInstance.task as CheckmarkTask,
          key: UniqueKey(),
          completionPeriod: taskInstance.completionPeriod,
        );
      case QuestionnaireTask _:
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
              Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                Flexible(
                  child: Text(
                    taskInstance.task.title ?? '',
                    style: theme.textTheme.headlineMedium!.copyWith(fontSize: 24),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 3,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.info_outline, color: Colors.grey),
                  onPressed: () => showDialog(
                    context: context,
                    builder: (context) {
                      return AlertDialog(
                        title: ListTile(
                          dense: true,
                          title: Text(taskInstance.task.title!, style: theme.textTheme.titleLarge),
                        ),
                        content: HtmlText(taskInstance.task.header),
                      );
                    },
                  ),
                ),
              ]),
              const SizedBox(height: 20),
              _buildTask()!,
            ],
          ),
        ),
      ),
    );
  }
}

handleTaskCompletion(BuildContext context, Function(StudySubject?) completionCallback) async {
  final state = context.read<AppState>();
  final activeSubject = state.activeSubject;
  try {
    if (state.trackParticipantProgress) {
      await completionCallback(activeSubject);
      Analytics.logger.info("Saved results in online mode");
    }
  } on SocketException catch (exception, stackTrace) {
    Analytics.logger.info("Saving results in offline mode");
    Analytics.captureEvent(exception, stackTrace: stackTrace);
    await Cache.storeSubject(activeSubject);
  } catch (exception, stackTrace) {
    Analytics.logger.severe("Could not save results");
    Analytics.captureException(exception, stackTrace: stackTrace);
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(AppLocalizations.of(context)!.could_not_save_results),
        duration: const Duration(seconds: 10),
        action: SnackBarAction(label: 'Retry', onPressed: () => handleTaskCompletion(context, completionCallback)),
      ),
    );
    rethrow;
  }
}
