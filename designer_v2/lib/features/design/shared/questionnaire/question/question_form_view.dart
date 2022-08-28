import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:reactive_forms/reactive_forms.dart';
import 'package:studyu_designer_v2/common_views/navbar_tabbed.dart';
import 'package:studyu_designer_v2/features/design/shared/questionnaire/question/question_form_tabs.dart';
import 'package:studyu_designer_v2/features/design/shared/questionnaire/question/types/bool_question_form_view.dart';
import 'package:studyu_designer_v2/features/design/shared/questionnaire/question/types/choice_question_form_view.dart';
import 'package:studyu_designer_v2/features/design/shared/questionnaire/question/types/scale_question_form_view.dart';
import 'package:studyu_designer_v2/features/design/shared/questionnaire/question/question_form_controller.dart';
import 'package:studyu_designer_v2/features/design/shared/questionnaire/question/types/question_type.dart';
import 'package:studyu_designer_v2/localization/string_hardcoded.dart';

/// Wrapper that dispatches to the appropriate widget for the corresponding
/// [SurveyQuestionType] as given by [formViewModel.questionType]
class SurveyQuestionFormView extends ConsumerWidget {
  const SurveyQuestionFormView({required this.formViewModel, Key? key})
      : super(key: key);

  final QuestionFormViewModel formViewModel;

  WidgetBuilder get questionTypeBodyBuilder {
    final Map<SurveyQuestionType, WidgetBuilder> questionTypeWidgets = {
      SurveyQuestionType.choice: (_) =>
          ChoiceQuestionFormView(formViewModel: formViewModel),
      SurveyQuestionType.bool: (_) =>
          BoolQuestionFormView(formViewModel: formViewModel),
      SurveyQuestionType.scale: (_) =>
          ScaleQuestionFormView(formViewModel: formViewModel),
    };
    final questionType = formViewModel.questionType;

    if (!questionTypeWidgets.containsKey(questionType)) {
      throw Exception(
          "Failed to build widget for SurveyQuestionType $questionType because"
          "there is no registered WidgetBuilder");
    }
    final builder = questionTypeWidgets[questionType]!;
    return builder;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      children: [
        ReactiveDropdownField<SurveyQuestionType>(
          formControl: formViewModel.questionTypeControl,
          items: formViewModel.questionTypeControlOptions
              .map((option) => DropdownMenuItem(
                    value: option.value,
                    child: Text(option.label),
                  ))
              .toList(),
        ),
        const SizedBox(height: 12.0),
        Opacity(
          opacity: 0.9,
          child: TabbedNavbar(
            tabs: QuestionFormTabs.tabs(context,
                questionTypeBodyBuilder(context) as IQuestionTypeFormWidget),
            height: 42.0,
            disabledTooltipText:
                "Not available for this question type".hardcoded,
          ),
        ),
        const Divider(height: 0),
        const SizedBox(height: 24.0),
        ReactiveValueListenableBuilder( // re-render when question type changes
          formControl: formViewModel.questionTypeControl,
          builder: (context, control, child) {
            return questionTypeBodyBuilder(context);
          },
        ),
      ],
    );
  }
}
