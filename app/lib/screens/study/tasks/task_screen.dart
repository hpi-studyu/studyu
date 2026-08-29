import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:studyu_app/l10n/app_localizations.dart';
import 'package:studyu_app/models/app_state.dart';
import 'package:studyu_app/screens/study/tasks/intervention/checkmark_task_widget.dart';
import 'package:studyu_app/screens/study/tasks/observation/questionnaire_task_widget.dart';
import 'package:studyu_app/util/cache.dart';
import 'package:studyu_app/widgets/html_text.dart';
import 'package:studyu_core/core.dart';
import 'package:studyu_flutter_common/studyu_flutter_common.dart';

class TaskScreen extends StatefulWidget {
  final TaskInstance taskInstance;

  static MaterialPageRoute<bool> routeFor({
    required TaskInstance taskInstance,
  }) =>
      MaterialPageRoute(builder: (_) => TaskScreen(taskInstance: taskInstance));

  const TaskScreen({required this.taskInstance, super.key});

  @override
  State<TaskScreen> createState() => _TaskScreenState();
}

class _TaskScreenState extends State<TaskScreen> {
  Widget _buildTask() {
    final taskInstance = widget.taskInstance;
    switch (taskInstance.task) {
      case final CheckmarkTask checkmarkTask:
        return SingleChildScrollView(
          child: SizedBox(
            width: MediaQuery.of(context).size.width,
            child: Column(
              children: [
                HtmlText(taskInstance.task.header, centered: true),
                const SizedBox(height: 20),
                CheckmarkTaskWidget(
                  task: checkmarkTask,
                  key: UniqueKey(),
                  interventionId: taskInstance.interventionId,
                  completionPeriod: taskInstance.completionPeriod,
                ),
              ],
            ),
          ),
        );
      case final QuestionnaireTask questionnaireTask:
        return QuestionnaireTaskWidget(
          task: questionnaireTask,
          key: UniqueKey(),
          interventionId: taskInstance.interventionId,
          completionPeriod: taskInstance.completionPeriod,
        );
      default:
        throw ArgumentError('Task ${taskInstance.task.type} not supported');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.taskInstance.task.title ?? '')),
      body: Padding(padding: const EdgeInsets.all(16), child: _buildTask()),
    );
  }
}

Future<bool> handleTaskCompletion(
  BuildContext context,
  Future<void> Function(StudySubject?) completionCallback, {
  required VoidCallback onCacheRetrySucceeded,
  Future<void> Function(StudySubject?)? cacheFallback,
}) {
  return Cache.runSubjectOperation(() async {
    final state = context.read<AppState>();
    final activeSubject = state.activeSubject;
    final wasConnectionDegraded =
        state.connectionStatus != AppConnectionStatus.healthy;
    var cacheWriteSucceeded = false;
    var cacheRetryInFlight = false;

    Future<bool> storeInCache() async {
      try {
        await (cacheFallback ?? Cache.storeSubject)(activeSubject);
        state.markActiveSubjectSynchronizationPending();
        cacheWriteSucceeded = true;
        debugPrint("Store subject in cache");
        return true;
      } catch (cacheError) {
        debugPrint("Could not cache results: $cacheError");
        if (!context.mounted) return false;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context)!.could_not_save_results),
            duration: const Duration(seconds: 10),
            persist: true,
            action: SnackBarAction(
              label: 'Retry',
              onPressed: () async {
                if (cacheRetryInFlight || cacheWriteSucceeded) return;
                cacheRetryInFlight = true;
                try {
                  if (await Cache.runSubjectOperation(storeInCache) &&
                      context.mounted) {
                    onCacheRetrySucceeded();
                  }
                } finally {
                  cacheRetryInFlight = false;
                }
              },
            ),
          ),
        );
        return false;
      }
    }

    if (!state.trackParticipantProgress) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            AppLocalizations.of(context)!.preview_mode_results_not_saved,
          ),
          duration: const Duration(seconds: 3),
        ),
      );
      return true;
    }

    try {
      await completionCallback(activeSubject);
    } catch (exception) {
      final status = connectionStatusFromError(exception);
      if (status != null) {
        state.setConnectionStatus(status);
      }
      debugPrint("Could not save results: $exception");
      return storeInCache();
    }

    if (wasConnectionDegraded) {
      return storeInCache();
    }
    state.setConnectionStatus(AppConnectionStatus.healthy);
    return true;
  });
}
