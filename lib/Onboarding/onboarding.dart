import 'dart:io';

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:research_package/research_package.dart';

import '../dashboard/dashboard.dart';

class OnboardingScreen extends StatefulWidget {
  final MaterialPageRoute route;

  OnboardingScreen({Key key, @required this.route}) : super(key: key);

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  void resultCallback(RPTaskResult result) {
    final formStepResult = result.getStepResultForIdentifier('onboardingFormStepID');
    Function eq = const ListEquality().equals;
    final resultValues = formStepResult.results.values.map((result) => result.results['answer'][0].value).toList();
    if (eq(resultValues, [1, 0, 42])) {
      Navigator.replaceRouteBelow(context,
          anchorRoute: widget.route, newRoute: MaterialPageRoute(builder: (context) => DashboardScreen()));
      //changeStatus(true);
    } else {
      exit(0);
    }
  }

  @override
  Widget build(BuildContext context) {
    return RPUITask(
      task: createOnboarding(),
      onSubmit: resultCallback,
    );
  }

  RPNavigableOrderedTask createOnboarding() {
    final overviewSection = RPConsentSection.withParams(RPConsentSectionType.Overview)
      ..summary = 'Welcome'
      ..content = 'We need data and therefore your consent.';

    final dataGatheringSection = RPConsentSection.withParams(RPConsentSectionType.DataGathering)
      ..summary = 'What we need:'
      ..content = 'EVERYTHING!';

    final consentDocument = RPConsentDocument.withParams(
      'Gathering consent',
      [overviewSection, dataGatheringSection],
    );

    final signature = RPConsentSignature.withIdentifier('consentSignatureID');
    consentDocument.addSignature(signature);

    final consentVisualStep = RPVisualConsentStep('visualConsentStepID', consentDocument);

    final consentReviewStep = RPConsentReviewStep('consentReviewstepID', consentDocument)
      ..reasonForConsent = 'By tapping AGREE you can take part in the study'
      ..text = 'Agreed?'
      ..title = 'Review';

    final instructionStep = RPInstructionStep(
        identifier: 'instructionID',
        title: 'Welcome',
        detailText: 'This is detailText',
        footnote: '(1) Important footnote')
      ..text = 'This survey decides, whether you are eligible for No1-trials.';

    /*RPBooleanAnswerFormat yesNoAnswerFormat =
        RPBooleanAnswerFormat.withParams('Yes', 'No');*/
    final yesNoChoices = [RPChoice.withParams('yes', 1), RPChoice.withParams('no', 0)];

    final backPainChoiceAnswerFormat = RPChoiceAnswerFormat.withParams(ChoiceAnswerStyle.SingleChoice, yesNoChoices);

    final backPainQuestionStep = RPQuestionStep.withAnswerFormat(
      'backPainQuestionStepID',
      'Have you had back pain in the last 2 weeks?',
      backPainChoiceAnswerFormat,
    );

    final pregnancyChoices = [
      RPChoice.withParams('Yes', 1),
      RPChoice.withParams('No', 0),
      RPChoice.withParams('Not sure', 2)
    ];

    final pregnancyChoiceAnswerFormat =
        RPChoiceAnswerFormat.withParams(ChoiceAnswerStyle.SingleChoice, pregnancyChoices);

    final pregnancyChoiceQuestionStep = RPQuestionStep.withAnswerFormat(
      'pregnancyChoiceQuestionStepID',
      'Are you pregnant?',
      pregnancyChoiceAnswerFormat,
    );

    final numberChoices = [RPChoice.withParams('1', 1), RPChoice.withParams('42', 42), RPChoice.withParams('137', 137)];

    final numberChoiceAnswerFormat = RPChoiceAnswerFormat.withParams(ChoiceAnswerStyle.SingleChoice, numberChoices);

    final numberChoiceQuestionStep = RPQuestionStep.withAnswerFormat(
      'numberChoiceQuestionStepID',
      'Select the best number.',
      numberChoiceAnswerFormat,
    );

    final onboardingFormStep = RPFormStep.withTitle('onboardingFormStepID',
        [backPainQuestionStep, pregnancyChoiceQuestionStep, numberChoiceQuestionStep], 'Onboarding');

    final completionStep = RPCompletionStep('completionStepID')
      ..title = 'Thank You!'
      ..text = 'We will evaluate your results.';

    final backPainSurveyTask = RPNavigableOrderedTask('backPainSurveyTaskID',
        [consentVisualStep, consentReviewStep, instructionStep, onboardingFormStep, completionStep]);

    return backPainSurveyTask;
  }
}
