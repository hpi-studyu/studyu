import 'package:flutter/material.dart';
import 'package:research_package/research_package.dart';

import 'DashboardTask.dart';

class PainRatingTask extends DashboardTask {
  PainRatingTask(String title, String description) : super(title, description);

  @override
  State<PainRatingTask> createState() => _PainRatingTaskState();
}

class _PainRatingTaskState extends State<PainRatingTask> {
  @override
  Widget build(BuildContext context) {
    return RPUITask(
      task: createSurvey(),
      onSubmit: (result) {},
    );
  }

  RPNavigableOrderedTask createSurvey() {
    RPSliderAnswerFormat painScaleAnswerFormat =
    RPSliderAnswerFormat.withParams(0, 10, divisions: 10);
    RPQuestionStep painRatingQuestionStep = RPQuestionStep.withAnswerFormat(
      "painRatingQuestionStepID",
      "How would you rate your pain today? (0 = no pain, 10 = extreme pain)",
      painScaleAnswerFormat,
    );

    RPCompletionStep completionStep = RPCompletionStep("completionStepID")
      ..title = 'Thank you for your input'
      ..text = '';

    return RPNavigableOrderedTask(
      'painSurveyTaskID',
      [painRatingQuestionStep, completionStep],
    );
  }
}
