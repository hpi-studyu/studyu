import 'package:Nof1/models/models.dart';
import 'package:Nof1/util/localization.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:research_package/research_package.dart';

import '../dashboard/dashboard.dart';
import '../database/models/question.dart';
import '../database/repository.dart';

class EligibilityCheckScreen extends StatefulWidget {
  final MaterialPageRoute route;
  final Study study;

  EligibilityCheckScreen({Key key, @required this.study, @required this.route}) : super(key: key);

  @override
  State<EligibilityCheckScreen> createState() => _EligibilityCheckScreenState();
}

class _EligibilityCheckScreenState extends State<EligibilityCheckScreen> {
  void resultCallback(RPTaskResult result) {
    final formStepResult = result.getStepResultForIdentifier('onboardingFormStepID');
    Function eq = const ListEquality().equals;
    final resultValues = formStepResult.results.values.map((result) => result.results['answer'][0].value).toList();
    if (eq(resultValues, [0, 1, 1])) {
      Navigator.replaceRouteBelow(context,
          anchorRoute: widget.route, newRoute: MaterialPageRoute(builder: (context) => DashboardScreen()));
      //changeStatus(true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: QuestionRepository().getQuestions(),
        builder: (_context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            if (snapshot.hasData) {
              return RPUITask(
                task: createOnboarding(context, snapshot.data, widget.study),
                onSubmit: resultCallback,
              );
            } else {
              return Center(
                child: Text("No Questions"),
              );
            }
          } else {
            return Center(child: CircularProgressIndicator());
          }
        });
  }

  RPNavigableOrderedTask createOnboarding(BuildContext context, List<Question> questions, Study study) {
    final instructionStep = RPInstructionStep(
        identifier: 'instructionID',
        title: Nof1Localizations.of(context).translate(study.id),
        detailText: 'This is detailText',
        footnote: '(1) Important footnote')
      ..text = 'This survey decides, whether you are eligible for the back pain study.';

    final questionSteps = questions.map((question) {
      final choices = [RPChoice.withParams(question.option1, 0), RPChoice.withParams(question.option2, 1)];
      final answerFormat = RPChoiceAnswerFormat.withParams(ChoiceAnswerStyle.SingleChoice, choices);
      return RPQuestionStep.withAnswerFormat("question${question.id}", question.question, answerFormat);
    }).toList();

    final onboardingFormStep = RPFormStep.withTitle('onboardingFormStepID', questionSteps, 'Onboarding');

    final completionStep = RPCompletionStep('completionStepID')
      ..title = 'Thank You!'
      ..text = 'Continue for your results.';

    final backPainSurveyTask =
        RPNavigableOrderedTask('backPainSurveyTaskID', [instructionStep, onboardingFormStep, completionStep]);

    return backPainSurveyTask;
  }
}
