import 'package:fhir/r4.dart' as fhir;
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import 'package:studyu_core/core.dart';
import 'package:supabase/supabase.dart';

import '../../../../models/app_state.dart';
import '../../../../widgets/fhir_questionnaire/questionnaire_widget.dart';
import '../../../../widgets/questionnaire/questionnaire_widget.dart';

class QuestionnaireTaskWidget extends StatefulWidget {
  final QuestionnaireTask task;

  const QuestionnaireTaskWidget({@required this.task, Key key}) : super(key: key);

  @override
  State<QuestionnaireTaskWidget> createState() => _QuestionnaireTaskWidgetState();
}

class _QuestionnaireTaskWidgetState extends State<QuestionnaireTaskWidget> {
  dynamic response;

  Future<void> _addQuestionnaireResult<T>(T response, BuildContext context) async {
    final state = context.read<AppState>();
    final activeStudy = state.activeSubject;
    try {
      if (state.trackParticipantProgress) {
        await activeStudy.addResult<T>(taskId: widget.task.id, result: response);
      }
      if (!mounted) return;
      Navigator.pop(context, true);
    } on PostgrestException {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context).could_not_save_results),
          duration: const Duration(seconds: 10),
          action: SnackBarAction(label: 'retry', onPressed: () => _addQuestionnaireResult(response, context)),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final fhirQuestionnaire = context.watch<AppState>().activeSubject.study.fhirQuestionnaire;
    final questionnaireWidget = fhirQuestionnaire != null
        ? FhirQuestionnaireWidget(
            fhirQuestionnaire,
            onComplete: (response) => setState(() {
              response = response;
            }),
          )
        : QuestionnaireWidget(
            widget.task.questions.questions,
            header: widget.task.header,
            footer: widget.task.footer,
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
          if (response != null)
            ElevatedButton.icon(
              style: ButtonStyle(backgroundColor: MaterialStateProperty.all<Color>(Colors.green)),
              onPressed: () {
                switch (response.runtimeType) {
                  case QuestionnaireState:
                    _addQuestionnaireResult<QuestionnaireState>(response as QuestionnaireState, context);
                    break;
                  case fhir.QuestionnaireResponse:
                    _addQuestionnaireResult<fhir.QuestionnaireResponse>(
                      response as fhir.QuestionnaireResponse,
                      context,
                    );
                    break;
                }
              },
              icon: const Icon(Icons.check),
              label: const Text('Complete'),
            )
        ],
      ),
    );
  }
}
