import 'package:flutter/material.dart';
import 'package:reactive_forms/reactive_forms.dart';
import 'package:studyu_designer_v2/common_views/form_input_decoration.dart';
import 'package:studyu_designer_v2/common_views/form_table_layout.dart';
import 'package:studyu_designer_v2/features/design/shared/questionnaire/question/question_form_controller.dart';
import 'package:studyu_designer_v2/features/design/shared/questionnaire/question/types/question_type.dart';
import 'package:studyu_designer_v2/localization/string_hardcoded.dart';
import 'package:studyu_designer_v2/localization/app_translation.dart';

// TODO needs finished concept/design
class BoolQuestionFormView extends StatelessWidget {
  const BoolQuestionFormView({
    required this.formViewModel,
    Key? key
  }) : super(key: key);

  final QuestionFormViewModel formViewModel;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        FormTableLayout(
            rows: [
              FormTableRow(
                control: formViewModel.questionTextControl,
                label: tr.text,
                labelStyle: const TextStyle(fontWeight: FontWeight.bold),
                labelHelpText: tr.question_text_help_text,
                input: ReactiveTextField(
                  formControl: formViewModel.questionTextControl,
                ),
              ),
              FormTableRow(
                control: formViewModel.questionTypeControl,
                label: tr.type,
                input: ReactiveDropdownField<SurveyQuestionType>(
                  formControl: formViewModel.questionTypeControl,
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
