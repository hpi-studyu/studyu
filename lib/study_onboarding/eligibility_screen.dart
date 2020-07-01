import 'package:flutter/material.dart';

import '../database/models/eligibility/eligibility_criterion.dart';
import '../database/models/questionnaire/question.dart';
import '../questionnaire_widgets/questionnaire_widget.dart';
import 'onboarding_progress.dart';

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
        bottom: OnboardingProgress(stage: 0, progress: 0.5),
      ),
      body: QuestionnaireWidget(questions, title: title, criteria: criteria),
    );
  }
}
