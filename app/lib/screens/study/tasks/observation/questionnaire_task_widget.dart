import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:postgrest/postgrest.dart';
import 'package:provider/provider.dart';
import 'package:studyou_core/models/models.dart';
import 'package:fhir/r4.dart' as fhir;
import 'package:studyou_core/models/results/result.dart';
import 'package:studyu/widgets/fhir_questionnaire/questionnaire_widget.dart';
import 'package:studyu/widgets/questionnaire/questionnaire_widget.dart';

import '../../../../models/app_state.dart';

class QuestionnaireTaskWidget extends StatelessWidget {
  final QuestionnaireTask task;

  const QuestionnaireTaskWidget({@required this.task, Key key}) : super(key: key);

  Future<void> _addQuestionnaireResponseFhir(fhir.QuestionnaireResponse response, BuildContext context) async {
    final model = context.read<AppState>();
    final activeStudy = model.activeStudy;
    final result = Result<fhir.QuestionnaireResponse>()
      ..type = 'fhir.QuestionnaireResponse'
      ..result = response
      ..timeStamp = DateTime.now()
      ..taskId = task.id;
    activeStudy.addResult(result);
    try {
      await activeStudy.save();
      Navigator.pop(context, true);
    } on PostgrestError {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(AppLocalizations.of(context).could_not_save_results),
        duration: Duration(seconds: 10),
        action: SnackBarAction(label: 'retry', onPressed: () => _addQuestionnaireResponseFhir(response, context)),
      ));
    }
  }

  Future<void> _addQuestionnaireResponseStudyU(QuestionnaireState qs, BuildContext context) async {
    final model = context.read<AppState>();
    final activeStudy = model.activeStudy;
    final result = Result<QuestionnaireState>()
      ..type = 'QuestionnaireState'
      ..result = qs
      ..timeStamp = DateTime.now()
      ..taskId = task.id;
    activeStudy.addResult(result);
    try {
      await activeStudy.save();
      Navigator.pop(context, true);
    } on PostgrestError {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(AppLocalizations.of(context).could_not_save_results),
        duration: Duration(seconds: 10),
        action: SnackBarAction(label: 'retry', onPressed: () => _addQuestionnaireResponseStudyU(qs, context)),
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    final fhirQuestionnaire = context.read<AppState>().activeStudy.fhirQuestionnaire;
    final questionnaireWidget = fhirQuestionnaire != null
        ? FhirQuestionnaireWidget(
            context.read<AppState>().activeStudy.fhirQuestionnaire,
            onComplete: (qs) => _addQuestionnaireResponseFhir(qs, context),
          )
        : QuestionnaireWidget(
            task.questions.questions,
            onComplete: (qs) => _addQuestionnaireResponseStudyU(qs, context),
          );
    return Expanded(
      child: questionnaireWidget,
    );
  }
}
