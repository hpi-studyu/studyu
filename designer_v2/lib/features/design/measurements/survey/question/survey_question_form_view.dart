import 'package:flutter/material.dart';
import 'package:reactive_forms/reactive_forms.dart';
import 'package:studyu_designer_v2/common_views/form_consumer_widget.dart';
import 'package:studyu_designer_v2/features/design/measurements/survey/question/bool_question_form_view.dart';
import 'package:studyu_designer_v2/features/design/measurements/survey/question/choice_question_form_view.dart';
import 'package:studyu_designer_v2/features/design/measurements/survey/question/scale_question_form_view.dart';
import 'package:studyu_designer_v2/features/design/measurements/survey/question/survey_question_form_controller.dart';
import 'package:studyu_designer_v2/features/design/measurements/survey/question/survey_question_type.dart';

/// Wrapper that dispatches to the appropriate widget for the corresponding
/// [SurveyQuestionType] as given by [formViewModel.questionType]
class SurveyQuestionFormView extends FormConsumerWidget {
  const SurveyQuestionFormView({
    required this.formViewModel,
    Key? key
  }) : super(key: key);

  final SurveyQuestionFormViewModel formViewModel;

  @override
  Widget build(BuildContext context, FormGroup form) {
    final Map<SurveyQuestionType, WidgetBuilder> questionTypeWidgets = {
      SurveyQuestionType.choice: (_) => ChoiceQuestionFormView(formViewModel: formViewModel),
      SurveyQuestionType.bool: (_) => BoolQuestionFormView(formViewModel: formViewModel),
      SurveyQuestionType.scale: (_) => ScaleQuestionFormView(formViewModel: formViewModel),
    };
    final questionType = formViewModel.questionType;

    if (!questionTypeWidgets.containsKey(questionType)) {
      throw Exception(
          "Failed to build widget for SurveyQuestionType $questionType because"
          "there is no registered WidgetBuilder");
    }
    final builder = questionTypeWidgets[questionType]!;
    return builder(context);
  }
}
