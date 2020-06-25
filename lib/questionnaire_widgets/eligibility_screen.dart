import 'package:flutter/material.dart';

import '../database/models/eligibility/eligibility_criterion.dart';
import '../database/models/questionnaire/question.dart';
import '../database/models/questionnaire/questionnaire_state.dart';
import 'questionnaire_widget.dart';

class QuestionnaireResult {
  final bool conditionResult;
  final QuestionnaireState answers;

  QuestionnaireResult(this.answers, {this.conditionResult});
}

class EligibilityScreen extends StatelessWidget {
  static MaterialPageRoute<QuestionnaireResult> routeFor(List<Question> questions,
          {@required String title, List<EligibilityCriterion> criteria}) =>
      MaterialPageRoute(
          builder: (_) => EligibilityScreen(questions, title: title, criteria: criteria),
          settings: RouteSettings(name: 'eligibilityCheck'));

  final String title;
  final List<Question> questions;
  final List<EligibilityCriterion> criteria;

  const EligibilityScreen(this.questions, {this.title, this.criteria, Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
      ),
      body: QuestionnaireWidget(questions, title: title, criteria: criteria),
    );
  }
}
