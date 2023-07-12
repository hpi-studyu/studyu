import 'dart:io';

import 'package:fhir/r4.dart' as fhir;
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import 'package:studyu_app/screens/study/tasks/task_screen.dart';
import 'package:studyu_app/util/misc.dart';
import 'package:studyu_core/core.dart';
import 'package:studyu_app/models/app_state.dart';
import 'package:studyu_app/widgets/fhir_questionnaire/questionnaire_widget.dart';
import 'package:studyu_app/widgets/questionnaire/questionnaire_widget.dart';

class ImageCapturingTaskWidget extends StatefulWidget {
  final ImageCapturingTask task;
  final CompletionPeriod completionPeriod;

  const ImageCapturingTaskWidget({required this.task, required this.completionPeriod, Key? key}) : super(key: key);

  @override
  State<ImageCapturingTaskWidget> createState() => _ImageCapturingTaskWidgetState();
}

class _ImageCapturingTaskWidgetState extends State<ImageCapturingTaskWidget> {
  dynamic response;
  late bool responseValidator;
  DateTime? loginClickTime;
  bool _isLoading = false;

  Future<void> _addImageResult<T>(T response, BuildContext context) async {
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
    final fhirQuestionnaire = context.watch<AppState>().activeSubject!.study.fhirQuestionnaire;
    final questionnaireWidget = fhirQuestionnaire != null
        ? FhirQuestionnaireWidget(
      fhirQuestionnaire,
      onComplete: (responseLocal) => setState(() {
        response = responseLocal;
      }),
    )
        : QuestionnaireWidget(
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
                  case QuestionnaireState:
                    await _addQuestionnaireResult<QuestionnaireState>(response as QuestionnaireState, context);
                    break;
                  case fhir.QuestionnaireResponse:
                    await _addQuestionnaireResult<fhir.QuestionnaireResponse?>(
                      response as fhir.QuestionnaireResponse?,
                      context,
                    );
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
