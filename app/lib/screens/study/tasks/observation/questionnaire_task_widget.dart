import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:studyou_core/models/models.dart';
import 'package:studyou_core/models/results/result.dart';
import 'package:studyou_core/queries/queries.dart';

import '../../../../models/app_state.dart';
import '../../../../util/localization.dart';
import '../../../../widgets/questionnaire/questionnaire_widget.dart';

class QuestionnaireTaskWidget extends StatelessWidget {
  final QuestionnaireTask task;

  const QuestionnaireTaskWidget({@required this.task, Key key}) : super(key: key);

  Future<void> _evaluateResponse(QuestionnaireState qs, BuildContext context) async {
    final model = context.read<AppModel>();
    final activeStudy = model.activeStudy;
    final result = Result<QuestionnaireState>()
      ..result = qs
      ..timeStamp = DateTime.now()
      ..taskId = task.id;
    activeStudy.addResult(result);
    if (await StudyQueries.saveUserStudy(activeStudy) != null) {
      Navigator.pop(context, true);
    } else {
      Scaffold.of(context).showSnackBar(SnackBar(
        content: Text(Nof1Localizations.of(context).translate('could_not_save_results')),
        duration: Duration(seconds: 10),
        action: SnackBarAction(label: 'retry', onPressed: () => _evaluateResponse(qs, context)),
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: QuestionnaireWidget(
        task.questions.questions,
        onComplete: (qs) => _evaluateResponse(qs, context),
      ),
    );
  }
}
