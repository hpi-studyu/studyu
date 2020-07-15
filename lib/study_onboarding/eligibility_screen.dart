import 'package:flutter/material.dart';
import 'package:nof1_models/models/models.dart';

import '../questionnaire_widgets/questionnaire_widget.dart';
import 'onboarding_progress.dart';

class EligibilityResult {
  final bool conditionResult;
  final QuestionnaireState answers;

  EligibilityResult(this.answers, {this.conditionResult});
}

class EligibilityScreen extends StatelessWidget {
  static MaterialPageRoute<EligibilityResult> routeFor(List<Question> questions,
          {@required String title, List<EligibilityCriterion> criteria}) =>
      MaterialPageRoute(
          builder: (_) => EligibilityScreen(questions, title: title, criteria: criteria),
          settings: RouteSettings(name: '/eligibilityCheck'));

  final String title;
  final List<Question> questions;
  final List<EligibilityCriterion> criteria;

  const EligibilityScreen(this.questions, {this.title, this.criteria, Key key}) : super(key: key);

  void _evaluateResponse(QuestionnaireState qs, BuildContext context) {
    final conditionResult = criteria?.every((criterion) => criterion.isSatisfied(qs)) ?? true;
    Navigator.of(context).pop(EligibilityResult(qs, conditionResult: conditionResult));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        bottom: OnboardingProgress(stage: 0, progress: 0.5),
      ),
      body: QuestionnaireWidget(questions, title: title, onComplete: (qs) => _evaluateResponse(qs, context)),
    );
  }
}
