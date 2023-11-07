import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:studyu_app/screens/study/tasks/task_screen.dart';
import 'package:studyu_app/util/misc.dart';
import 'package:studyu_core/core.dart';
import 'package:studyu_app/widgets/questionnaire/questionnaire_widget.dart';

class QuestionnaireTaskWidget extends StatefulWidget {
  final QuestionnaireTask task;
  final CompletionPeriod completionPeriod;

  const QuestionnaireTaskWidget({required this.task, required this.completionPeriod, super.key});

  @override
  State<QuestionnaireTaskWidget> createState() => _QuestionnaireTaskWidgetState();
}

class _QuestionnaireTaskWidgetState extends State<QuestionnaireTaskWidget> {
  dynamic response;
  late bool responseValidator;
  DateTime? loginClickTime;
  bool _isLoading = false;

  Future<void> _addQuestionnaireResult<T>(T response, BuildContext context) async {
    await handleTaskCompletion(context, (StudySubject? subject) async {
      try {
        await subject!.addResult<T>(taskId: widget.task.id, periodId: widget.completionPeriod.id, result: response);
      } on SocketException catch (_) {
        await subject!.addResult<T>(
            taskId: widget.task.id, periodId: widget.completionPeriod.id, result: response, offline: true);
        rethrow;
      }
    });
    if (!mounted) return;
    Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    final questionnaireWidget = QuestionnaireWidget(
      widget.task.questions.questions,
      header: widget.task.header,
      footer: widget.task.footer,
      onChange: _responseValidator,
      onComplete: (qs) => setState(() {
        response = qs;
      }),
    );
    return Expanded(
      child: Column(
        children: [
          Expanded(
            child: questionnaireWidget,
          ),
          if (response != null && responseValidator)
            ElevatedButton.icon(
              style: ButtonStyle(backgroundColor: MaterialStateProperty.all<Color>(Colors.green)),
              onPressed: () async {
                if (isRedundantClick(loginClickTime)) {
                  return;
                }
                setState(() {
                  _isLoading = true;
                });
                switch (response.runtimeType) {
                  case QuestionnaireState _:
                    await _addQuestionnaireResult<QuestionnaireState>(response as QuestionnaireState, context);
                    break;
                }
                setState(() {
                  _isLoading = false;
                });
              },
              icon: _isLoading ? const CircularProgressIndicator(color: Colors.white) : const Icon(Icons.check),
              label: Text(AppLocalizations.of(context)!.complete),
            ),
        ],
      ),
    );
  }

  void _responseValidator(QuestionnaireState qs) {
    if (qs.answers.length == widget.task.questions.questions.length) {
      setState(() {
        responseValidator = true;
      });
    } else {
      setState(() {
        responseValidator = false;
      });
    }
  }
}
