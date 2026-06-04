import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:studyu_app/l10n/app_localizations.dart';
import 'package:studyu_app/screens/study/tasks/task_screen.dart';
import 'package:studyu_app/util/misc.dart';
import 'package:studyu_app/util/study_subject_extension.dart';
import 'package:studyu_app/util/temporary_storage_handler.dart';
import 'package:studyu_app/widgets/questionnaire/questionnaire_widget.dart';
import 'package:studyu_core/core.dart';

class QuestionnaireTaskWidget extends StatefulWidget {
  final QuestionnaireTask task;
  final CompletionPeriod completionPeriod;

  const QuestionnaireTaskWidget({
    required this.task,
    required this.completionPeriod,
    super.key,
  });

  @override
  State<QuestionnaireTaskWidget> createState() =>
      _QuestionnaireTaskWidgetState();
}

class _QuestionnaireTaskWidgetState extends State<QuestionnaireTaskWidget> {
  dynamic response;
  late bool responseValidator;
  DateTime? _lastClickTime;
  bool _isLoading = false;
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  final GlobalKey<QuestionnaireWidgetState> questionnaireKey =
      GlobalKey<QuestionnaireWidgetState>();

  Future<void> _addQuestionnaireResult<T>(
    T response,
    BuildContext context,
  ) async {
    await handleTaskCompletion(context, (StudySubject? subject) async {
      try {
        await subject!.addResult<T>(
          taskId: widget.task.id,
          periodId: widget.completionPeriod.id,
          result: response,
        );
      } catch (e) {
        print('Saving results to cache due to error: $e');
        await subject!.addResult<T>(
          taskId: widget.task.id,
          periodId: widget.completionPeriod.id,
          result: response,
          offline: true,
        );
        rethrow;
      }
    });
    if (!context.mounted) return;
    context.pop(true);
  }

  @override
  void dispose() {
    super.dispose();
    TemporaryStorageHandler.deleteAllStagingFiles();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: Form(
            key: formKey,
            child: QuestionnaireWidget(
              widget.task.questions.questions,
              key: questionnaireKey,
              taskId: widget.task.id,
              header: widget.task.header,
              footer: widget.task.footer,
              onComplete: (qs) => setState(() {
                print('Questionnaire completed with response: $qs');
                response = qs;
              }),
            ),
          ),
        ),
        if (response != null)
          ElevatedButton.icon(
            key: const ValueKey('questionnaire_complete'),
            style: ButtonStyle(
              backgroundColor: WidgetStateProperty.all<Color>(Colors.green),
            ),
            onPressed: () async {
              if (isRedundantClick(_lastClickTime)) return;
              final syncedResponse = questionnaireKey.currentState!
                  .validateSyncAndBuildPayload();
              if (syncedResponse == null) return;
              if (!formKey.currentState!.validate()) return;
              setState(() {
                _isLoading = true;
                _lastClickTime = DateTime.now();
              });
              switch (syncedResponse) {
                case final QuestionnaireState questionnaireState:
                  // Filter all skipped conditional questions
                  questionnaireState.answers.removeWhere(
                    (answer, answerValue) => answerValue.response == null,
                  );
                  await _addQuestionnaireResult<QuestionnaireState>(
                    questionnaireState,
                    context,
                  );
              }
              setState(() {
                _isLoading = false;
              });
            },
            icon: _isLoading
                ? const CircularProgressIndicator(color: Colors.white)
                : const Icon(Icons.check),
            label: Text(AppLocalizations.of(context)!.complete),
          )
        else
          const SizedBox.shrink(),
      ],
    );
  }
}
