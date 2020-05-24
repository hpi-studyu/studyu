import 'package:flutter/foundation.dart' show listEquals;
import 'package:flutter/material.dart';
import 'package:research_package/research_package.dart';

import '../database/models/models.dart';
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
  void resultCallback(BuildContext context, RPTaskResult result) {
    final formStepResult = result.getStepResultForIdentifier('onboardingFormStepID');
    final resultValues = formStepResult.results.values.map((result) => result.results['answer'][0].value).toList();
    final isEligible = listEquals(resultValues, [0, 1, 1]);
    Navigator.of(context).pop(isEligible);
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
                onSubmit: (result) => resultCallback(context, result),
              );
            } else {
              return Center(
                child: Text('No Questions'),
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
        title: study.title,
        detailText: study.description,
        footnote: '(1) Important footnote')
      ..text = 'This survey decides, whether you are eligible for the ${study.title.toLowerCase()} study.';

    final questionSteps = questions.map((question) {
      final choices = [RPChoice.withParams(question.option1, 0), RPChoice.withParams(question.option2, 1)];
      final answerFormat = RPChoiceAnswerFormat.withParams(ChoiceAnswerStyle.SingleChoice, choices);
      return RPQuestionStep.withAnswerFormat('question${question.id}', question.question, answerFormat);
    }).toList();

    final onboardingFormStep = RPFormStep.withTitle('onboardingFormStepID', questionSteps, 'Onboarding');

    final completionStep = RPCompletionStep('completionStepID')
      ..title = 'Thank You!'
      ..text = 'Continue for your results.';

    final backPainSurveyTask = RPNavigableOrderedTask(
        'backPainSurveyTaskID', [instructionStep, onboardingFormStep, completionStep],
        closeAfterFinished: false);

    return backPainSurveyTask;
  }
}
