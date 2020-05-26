import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:research_package/research_package.dart';

import '../database/models/models.dart';
import '../database/models/questionnaire/answers/multiple_choice_answer.dart';
import '../database/models/questionnaire/questions/multiple_choice_question.dart';

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
    var isEligible = false;
    if (formStepResult != null) {
      var answers = HashMap();
      formStepResult.results.forEach((key, value) {
        final stepResult = (value as RPStepResult);
        switch (stepResult.answerFormat.runtimeType) {
          case RPChoiceAnswerFormat:
            answers[int.parse(key)] = MultipleChoiceAnswer(int.parse(key), DateTime.now(), int.parse(key), Set.from((stepResult.results['answer'] as List<RPChoice>).map<Choice>((choice) => Choice(choice.value, choice.text)).toList()));
            break;
          default:
            return null;
        }
      });

      isEligible = !widget.study.conditions.map<bool>((condition) => condition.checkAnswer(answers[condition.questionId])).any((element) => element == false);
    }
    Navigator.of(context).pop(isEligible);
  }

  @override
  Widget build(BuildContext context) {
    return RPUITask(
      task: createOnboarding(context, widget.study),
      onSubmit: (result) => resultCallback(context, result),
    );
  }

  RPNavigableOrderedTask createOnboarding(BuildContext context, Study study) {
    final instructionStep = RPInstructionStep(identifier: 'instructionID', title: study.title, detailText: study.description, footnote: '(1) Important footnote')..text = 'This survey decides, whether you are eligible for the ${study.title.toLowerCase()} study.';

    final questionSteps = study.eligibility
        .map((question) {
          switch (question.runtimeType) {
            case MultipleChoiceQuestion:
              final choices = <RPChoice>[];
              for (var choice in (question as MultipleChoiceQuestion).choices) {
                final choiceStep = RPChoice.withParams(choice.value, choice.id);
                choices.add(choiceStep);
              }
              final answerFormat = RPChoiceAnswerFormat.withParams((question as MultipleChoiceQuestion).multiple ? ChoiceAnswerStyle.MultipleChoice : ChoiceAnswerStyle.SingleChoice, choices);
              return RPQuestionStep.withAnswerFormat('${question.id}', question.question, answerFormat);
            default:
              return null;
          }
        })
        .where((element) => element != null)
        .toList();

    final onboardingFormStep = RPFormStep.withTitle('onboardingFormStepID', questionSteps, 'Onboarding');

    final completionStep = RPCompletionStep('completionStepID')
      ..title = 'Thank You!'
      ..text = 'Continue for your results.';

    final steps = [
      instructionStep,
      completionStep
    ];

    if (questionSteps.isNotEmpty) {
      steps.insert(1, onboardingFormStep);
    }

    final backPainSurveyTask = RPNavigableOrderedTask('backPainSurveyTaskID', steps, closeAfterFinished: false);

    return backPainSurveyTask;
  }
}
