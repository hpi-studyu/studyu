import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import 'package:studyou_core/models/models.dart';
import 'package:studyou_core/models/results/result.dart';
import 'package:studyu/widgets/fhir_questionnaire/questionnaire_widget.dart';

import '../../../../models/app_state.dart';

class QuestionnaireTaskWidget extends StatelessWidget {
  final QuestionnaireTask task;

  const QuestionnaireTaskWidget({@required this.task, Key key}) : super(key: key);

  Future<void> _addQuestionnaireResponse(QuestionnaireState qs, BuildContext context) async {
    final model = context.read<AppState>();
    final activeStudy = model.activeStudy;
    final result = Result<QuestionnaireState>()
      ..result = qs
      ..timeStamp = DateTime.now()
      ..taskId = task.id;
    activeStudy.addResult(result);
    if (await activeStudy.saveUserStudy() != null) {
      Navigator.pop(context, true);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(AppLocalizations.of(context).could_not_save_results),
        duration: Duration(seconds: 10),
        action: SnackBarAction(label: 'retry', onPressed: () => _addQuestionnaireResponse(qs, context)),
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: FhirQuestionnaireWidget(
        context.read<AppState>().activeStudy.fhirQuestionnaire,
        onComplete: (qs) => _addQuestionnaireResponse(qs, context),
      ),
    );
  }
}
