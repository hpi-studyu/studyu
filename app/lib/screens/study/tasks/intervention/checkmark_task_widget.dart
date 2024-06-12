import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
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
  DateTime _lastClickTime = DateTime.now();
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      style: ButtonStyle(
        backgroundColor: WidgetStateProperty.all<Color>(Colors.green),
        textStyle: WidgetStateProperty.all<TextStyle>(
          const TextStyle(color: Colors.white),
        ),
      ),
      onPressed: () async {
        if (isRedundantClick(_lastClickTime)) return;
        setState(() {
          _isLoading = true;
          _lastClickTime = DateTime.now();
        });
        await handleTaskCompletion(context, (StudySubject? subject) async {
          try {
            await subject!.addResult<bool>(
              taskId: widget.task!.id,
              periodId: widget.completionPeriod!.id,
              result: true,
            );
          } on SocketException catch (_) {
            await subject!.addResult<bool>(
              taskId: widget.task!.id,
              periodId: widget.completionPeriod!.id,
              result: true,
              offline: true,
            );
            rethrow;
          }
        });
        setState(() {
          _isLoading = false;
        });
        if (!context.mounted) return;
        Navigator.pop(context, true);
      },
      icon: _isLoading
          ? const CircularProgressIndicator(color: Colors.white)
          : const Icon(Icons.check),
      label: Text(AppLocalizations.of(context)!.complete),
    );
  }
}
