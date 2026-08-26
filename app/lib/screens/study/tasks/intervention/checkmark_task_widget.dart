import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:studyu_app/l10n/app_localizations.dart';
import 'package:studyu_app/screens/study/tasks/task_screen.dart';
import 'package:studyu_app/util/misc.dart';
import 'package:studyu_app/util/study_subject_extension.dart';
import 'package:studyu_core/core.dart';

class CheckmarkTaskWidget extends StatefulWidget {
  final CheckmarkTask? task;
  final CompletionPeriod? completionPeriod;

  const CheckmarkTaskWidget({this.task, this.completionPeriod, super.key});

  @override
  State<CheckmarkTaskWidget> createState() => _CheckmarkTaskWidgetState();
}

class _CheckmarkTaskWidgetState extends State<CheckmarkTaskWidget> {
  DateTime? _lastClickTime;
  bool _isLoading = false;
  bool _isPendingCacheWrite = false;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      style: ButtonStyle(
        backgroundColor: WidgetStateProperty.all<Color>(Colors.green),
        textStyle: WidgetStateProperty.all<TextStyle>(
          const TextStyle(color: Colors.white),
        ),
      ),
      onPressed: _isLoading || _isPendingCacheWrite
          ? null
          : () async {
              if (isRedundantClick(_lastClickTime)) return;
              setState(() {
                _isLoading = true;
                _lastClickTime = DateTime.now();
              });
              final completed = await handleTaskCompletion(
                context,
                (StudySubject? subject) async {
                  await subject!.addResult<bool>(
                    taskId: widget.task!.id,
                    periodId: widget.completionPeriod!.id,
                    result: true,
                  );
                },
                onCacheRetrySucceeded: () {
                  if (context.mounted) context.pop(true);
                },
              );
              if (!context.mounted) return;
              setState(() {
                _isLoading = false;
                _isPendingCacheWrite = !completed;
              });
              if (completed) {
                context.pop(true);
              }
            },
      icon: _isLoading
          ? const CircularProgressIndicator(color: Colors.white)
          : const Icon(Icons.check),
      label: Text(AppLocalizations.of(context)!.complete),
    );
  }
}
