import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:studyu_app/screens/study/tasks/task_screen.dart';
import 'package:studyu_app/util/misc.dart';
import 'package:studyu_core/core.dart';

class ImageCapturingTaskWidget extends StatefulWidget {
  final ImageCapturingTask? task;
  final CompletionPeriod? completionPeriod;

  const ImageCapturingTaskWidget({this.task, this.completionPeriod, Key? key}) : super(key: key);

  @override
  State<ImageCapturingTaskWidget> createState() => _ImageCapturingTaskWidgetState();
}

class _ImageCapturingTaskWidgetState extends State<ImageCapturingTaskWidget> {
  DateTime? loginClickTime;
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      style: ButtonStyle(backgroundColor: MaterialStateProperty.all<Color>(Colors.green)),
      onPressed: () async {
        if (isRedundantClick(loginClickTime)) return;
        setState(() {
          _isLoading = true;
        });
        await handleTaskCompletion(context, (StudySubject? subject) async {
          try {
            await subject!
            //TODO: .addResult<ImageResponse>
                .addResult<bool>(taskId: widget.task!.id, periodId: widget.completionPeriod!.id, result: true);
          } on SocketException catch (_) {
            await subject!.addResult<bool>(
                taskId: widget.task!.id, periodId: widget.completionPeriod!.id, result: true, offline: true);
            rethrow;
          }
        });
        setState(() {
          _isLoading = false;
        });
        if (!mounted) return;
        Navigator.pop(context, true);
      },
      icon: _isLoading ? const CircularProgressIndicator(color: Colors.white) : const Icon(Icons.check),
      label: Text(AppLocalizations.of(context)!.complete),
    );
  }
}
