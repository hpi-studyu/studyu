import 'dart:io';
import 'package:app/Dashboard/Dashboard.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:research_package/research_package.dart';

class OnboardingScreen extends StatefulWidget {
  final MaterialPageRoute route;

  OnboardingScreen({Key key, @required this.route}) : super(key: key);

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  resultCallback(RPTaskResult result) {
    RPStepResult formStepResult =
    result.getStepResultForIdentifier('onboardingFormStepID');
    Function eq = const ListEquality().equals;
    List<dynamic> resultValues = formStepResult.results.values
        .map((result) => result.results['answer'][0].value)
        .toList();
    if (eq(resultValues, [1, 0, 42])) {
      Navigator.replaceRouteBelow(context,
          anchorRoute: widget.route,
          newRoute: MaterialPageRoute(builder: (context) => DashboardScreen()));
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
    RPConsentSection overviewSection =
    RPConsentSection.withParams(RPConsentSectionType.Overview)
      ..summary = 'Welcome'
      ..content = 'We need data and therefore your consent.';

    RPConsentSection dataGatheringSection =
    RPConsentSection.withParams(RPConsentSectionType.DataGathering)
      ..summary = 'What we need:'
      ..content = 'EVERYTHING!';

    RPConsentDocument consentDocument = RPConsentDocument.withParams(
      'Gathering consent',
      [overviewSection, dataGatheringSection],
    );

    RPConsentSignature signature =
    RPConsentSignature.withIdentifier('consentSignatureID');
    consentDocument.addSignature(signature);

    RPVisualConsentStep consentVisualStep =
    RPVisualConsentStep('visualConsentStepID', consentDocument);

    RPConsentReviewStep consentReviewStep =
    RPConsentReviewStep('consentReviewstepID', consentDocument)
      ..reasonForConsent = 'By tapping AGREE you can take part in the study'
      ..text = 'Agreed?'
      ..title = 'Review';

    RPInstructionStep instructionStep = RPInstructionStep(
        identifier: 'instructionID',
        title: 'Welcome',
        detailText: 'This is detailText',
        footnote: '(1) Important footnote')
      ..text = 'This survey decides, whether you are eligible for No1-trials.';

    /*RPBooleanAnswerFormat yesNoAnswerFormat =
        RPBooleanAnswerFormat.withParams('Yes', 'No');*/
    List<RPChoice> yesNoChoices = [
      RPChoice.withParams('yes', 1),
      RPChoice.withParams('no', 0)
    ];

    RPChoiceAnswerFormat backPainChoiceAnswerFormat =
    RPChoiceAnswerFormat.withParams(
        ChoiceAnswerStyle.SingleChoice, yesNoChoices);

    RPQuestionStep backPainQuestionStep = RPQuestionStep.withAnswerFormat(
      'backPainQuestionStepID',
      'Have you had back pain in the last 2 weeks?',
      backPainChoiceAnswerFormat,
    );

    List<RPChoice> pregnancyChoices = [
      RPChoice.withParams('Yes', 1),
      RPChoice.withParams('No', 0),
      RPChoice.withParams('Not sure', 2)
    ];

    RPChoiceAnswerFormat pregnancyChoiceAnswerFormat =
    RPChoiceAnswerFormat.withParams(
        ChoiceAnswerStyle.SingleChoice, pregnancyChoices);

    RPQuestionStep pregnancyChoiceQuestionStep =
    RPQuestionStep.withAnswerFormat(
      'pregnancyChoiceQuestionStepID',
      'Are you pregnant?',
      pregnancyChoiceAnswerFormat,
    );

    List<RPChoice> numberChoices = [
      RPChoice.withParams('1', 1),
      RPChoice.withParams('42', 42),
      RPChoice.withParams('137', 137)
    ];

    RPChoiceAnswerFormat numberChoiceAnswerFormat =
    RPChoiceAnswerFormat.withParams(
        ChoiceAnswerStyle.SingleChoice, numberChoices);

    RPQuestionStep numberChoiceQuestionStep = RPQuestionStep.withAnswerFormat(
      'numberChoiceQuestionStepID',
      'Select the best number.',
      numberChoiceAnswerFormat,
    );

    RPFormStep onboardingFormStep = RPFormStep.withTitle(
        'onboardingFormStepID',
        [
          backPainQuestionStep,
          pregnancyChoiceQuestionStep,
          numberChoiceQuestionStep
        ],
        'Onboarding');

    RPCompletionStep completionStep = RPCompletionStep('completionStepID')
      ..title = 'Thank You!'
      ..text = 'We will evaluate your results.';

    RPNavigableOrderedTask backPainSurveyTask =
    RPNavigableOrderedTask('backPainSurveyTaskID', [
      consentVisualStep,
      consentReviewStep,
      instructionStep,
      onboardingFormStep,
      completionStep
    ]);

    return backPainSurveyTask;
  }
}
