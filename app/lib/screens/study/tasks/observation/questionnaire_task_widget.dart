import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:studyu_app/screens/study/tasks/task_screen.dart';
import 'package:studyu_app/util/misc.dart';
import 'package:studyu_app/util/study_subject_extension.dart';
import 'package:studyu_app/util/temporary_storage_handler.dart';
import 'package:studyu_app/widgets/questionnaire/questionnaire_widget.dart';
import 'package:studyu_core/core.dart';

class QuestionnaireTaskWidget extends StatefulWidget {
  final QuestionnaireTask task;
  final String interventionId;
  final CompletionPeriod completionPeriod;

  const QuestionnaireTaskWidget({
    required this.task,
    required this.interventionId,
    required this.completionPeriod,
    super.key,
  });

  @override
  State<QuestionnaireTaskWidget> createState() =>
      _QuestionnaireTaskWidgetState();
}

class _QuestionnaireTaskWidgetState extends State<QuestionnaireTaskWidget> {
  DateTime? _lastClickTime;
  bool _isLoading = false;
  bool _isPendingCacheWrite = false;
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  final GlobalKey<QuestionnaireWidgetState> questionnaireKey =
      GlobalKey<QuestionnaireWidgetState>();

  Future<void> _addQuestionnaireResult<T>(
    T response,
    BuildContext context,
  ) async {
    final completed = await handleTaskCompletion(
      context,
      (StudySubject? subject) async {
        await subject!.addResult<T>(
          taskId: widget.task.id,
          interventionId: widget.interventionId,
          periodId: widget.completionPeriod.id,
          result: response,
        );
      },
      onCacheRetrySucceeded: () {
        if (context.mounted) context.pop(true);
      },
    );
    if (!context.mounted) return;
    if (!completed) {
      setState(() {
        _isPendingCacheWrite = true;
      });
      return;
    }
    context.pop(true);
  }

  @override
  void dispose() {
    super.dispose();
    TemporaryStorageHandler.deleteAllStagingFiles();
  }

  Future<void> _handleCompletion(QuestionnaireState? qs) async {
    if (kDebugMode) {
      debugPrint('Questionnaire completed with response: $qs');
    }
    // Only a non-null payload (all visible questions answered) submits.
    if (qs == null) return;
    if (isRedundantClick(_lastClickTime)) return;
    if (!formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _lastClickTime = DateTime.now();
    });

    // Filter all skipped conditional questions
    qs.answers.removeWhere(
      (answer, answerValue) => answerValue.response == null,
    );

    try {
      await _addQuestionnaireResult<QuestionnaireState>(qs, context);
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: formKey,
      child: QuestionnaireWidget(
        widget.task.questions.questions,
        key: questionnaireKey,
        taskId: widget.task.id,
        header: widget.task.header,
        footer: widget.task.footer,
        isSubmitting: _isLoading || _isPendingCacheWrite,
        onComplete: _handleCompletion,
      ),
    );
  }
}
