import 'package:flutter/material.dart';
import 'package:nof1_models/models/models.dart';

import '../questionnaire_widgets/questionnaire_widget.dart';

class QuestionnaireTaskWidget extends StatelessWidget {
  final QuestionnaireTask task;

  const QuestionnaireTaskWidget({@required this.task, Key key}) : super(key: key);

  void _evaluateResponse(QuestionnaireState qs, BuildContext context) {
    //TODO: Save QS

    Navigator.of(context).pop();
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
