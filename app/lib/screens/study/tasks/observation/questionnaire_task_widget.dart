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
  final CompletionPeriod completionPeriod;

  const QuestionnaireTaskWidget({@required this.task, @required this.completionPeriod, Key key}) : super(key: key);

  @override
  State<QuestionnaireTaskWidget> createState() => _QuestionnaireTaskWidgetState();
}

class _QuestionnaireTaskWidgetState extends State<QuestionnaireTaskWidget> {
  dynamic response;
  bool responseValidator;
  DateTime loginClickTime;

  Future<void> _addQuestionnaireResult<T>(T response, BuildContext context) async {
    final state = context.read<AppState>();
    final activeStudy = state.activeSubject;
    try {
      if (state.trackParticipantProgress) {
        await activeStudy.addResult<T>(taskId: widget.task.id, periodId: widget.completionPeriod.id, result: response);
      }
      if (!mounted) return;
      Navigator.pop(context, true);
    } on PostgrestException {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context).could_not_save_results),
          duration: const Duration(seconds: 10),
          action: SnackBarAction(label: 'Retry', onPressed: () => _addQuestionnaireResult(response, context)),
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
              onPressed: () {
                if (isRedundantClick(DateTime.now())) {
                  return;
                }
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
              label: Text(AppLocalizations.of(context).complete),
            )
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

  bool isRedundantClick(DateTime currentTime) {
    if (loginClickTime == null) {
      loginClickTime = currentTime;
      return false;
    }
    int secondsUntilClicked = currentTime.difference(loginClickTime).inSeconds;
    // timeout submit button to disable multiple clicks
    if (secondsUntilClicked < 3) {
      print('complete button is still freezed');
      return true;
    }

    loginClickTime = currentTime;
    return false;
  }
}
