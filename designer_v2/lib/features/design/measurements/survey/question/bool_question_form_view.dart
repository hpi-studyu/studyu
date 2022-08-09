import 'package:flutter/material.dart';
import 'package:reactive_forms/reactive_forms.dart';
import 'package:studyu_designer_v2/common_views/form_table_layout.dart';
import 'package:studyu_designer_v2/features/design/measurements/survey/question/survey_question_form_controller.dart';
import 'package:studyu_designer_v2/features/design/measurements/survey/question/survey_question_type.dart';
import 'package:studyu_designer_v2/localization/string_hardcoded.dart';

// TODO needs finished concept/design
class BoolQuestionFormView extends StatelessWidget {
  const BoolQuestionFormView({
    required this.formViewModel,
    Key? key
  }) : super(key: key);

  final SurveyQuestionFormViewModel formViewModel;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        FormTableLayout(
            rows: [
              FormTableRow(
                label: "Text".hardcoded,
                labelStyle: const TextStyle(fontWeight: FontWeight.bold),
                labelHelpText: "TODO Question text help text".hardcoded,
                input: ReactiveTextField(
                  formControl: formViewModel.questionTextControl,
                ),
              ),
              FormTableRow(
                label: "Type".hardcoded,
                input: ReactiveDropdownField<SurveyQuestionType>(
                  formControl: formViewModel.questionTypeControl,
                  decoration: const NullHelperDecoration(),
                  items: formViewModel.questionTypeControlOptions.map(
                          (option) => DropdownMenuItem(
                            value: option.value,
                            child: Text(option.label),
                          )).toList(),
                ),
              ),
            ]
        ),
      ],
    );
  }
}
