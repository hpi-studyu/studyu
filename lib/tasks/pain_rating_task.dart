import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:research_package/research_package.dart';

import '../util/localization.dart';
import 'dashboard_task.dart';

class PainRatingTask extends DashboardTask {
  PainRatingTask(String title, String description)
      : super(title, description, icon: Icon(MdiIcons.orderBoolAscendingVariant));

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
    final painScaleAnswerFormat = RPSliderAnswerFormat.withParams(0, 10, divisions: 10);
    final painRatingQuestionStep = RPQuestionStep.withAnswerFormat(
      'painRatingQuestionStepID',
      Nof1Localizations.of(context).translate('how_would_you_rate_your_pain_today'),
      painScaleAnswerFormat,
    );

    final completionStep = RPCompletionStep('completionStepID')
      ..title = Nof1Localizations.of(context).translate('thank_you_for_your_input')
      ..text = '';

    return RPNavigableOrderedTask(
      'painSurveyTaskID',
      [painRatingQuestionStep, completionStep],
    );
  }
}
