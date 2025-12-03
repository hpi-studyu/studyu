import 'package:flutter/material.dart';

import 'package:provider/provider.dart';
import 'package:studyu_app/l10n/app_localizations.dart';
import 'package:studyu_app/models/app_state.dart';
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
  QuestionnaireState? _initialState;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _loadExistingResult();
  }

  void _loadExistingResult() {
    if (_initialState != null) return;

    final subject = context.read<AppState>().activeSubject;
    if (subject == null) return;

    final existingProgress = subject.progress
        .where(
          (p) =>
              p.taskId == widget.task.id &&
              p.result.periodId == widget.completionPeriod.id,
        )
        .toList();

    if (existingProgress.isNotEmpty) {
      existingProgress.sort((a, b) => b.completedAt!.compareTo(a.completedAt!));

      final currentStudyDay = subject.getDayOfStudyFor(DateTime.now());

      for (final progress in existingProgress) {
        final progressStudyDay = subject.getDayOfStudyFor(
          progress.completedAt!,
        );
        if (progressStudyDay == currentStudyDay) {
          final resultData = progress.result.result;
          if (resultData is QuestionnaireState) {
            setState(() {
              _initialState = resultData;
            });
          } else if (resultData is List) {
            setState(() {
              _initialState = QuestionnaireState.fromJson(
                List<Map<String, dynamic>>.from(resultData),
              );
            });
          }
          break;
        }
      }
    }
  }

  Future<void> _addQuestionnaireResult<T>(
    T response,
    BuildContext context, {
    bool closeScreen = true,
  }) async {
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
    if (!context.mounted || !closeScreen) return;
    Navigator.pop(context, true);
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
              taskId: widget.task.id,
              header: widget.task.header,
              footer: widget.task.footer,
              initialState: _initialState,
              onComplete: (qs) => setState(() {
                print('Questionnaire completed with response: $qs');
                response = qs;
              }),
              onChange: (qs) {
                if (qs != null) {
                  _addQuestionnaireResult<QuestionnaireState>(
                    qs,
                    context,
                    closeScreen: false,
                  );
                }
              },
            ),
          ),
        ),
        if (response != null)
          ElevatedButton.icon(
            style: ButtonStyle(
              backgroundColor: WidgetStateProperty.all<Color>(Colors.green),
            ),
            onPressed: () async {
              if (isRedundantClick(_lastClickTime)) return;
              if (!formKey.currentState!.validate()) return;
              setState(() {
                _isLoading = true;
                _lastClickTime = DateTime.now();
              });
              switch (response) {
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
