import 'package:flutter/material.dart';
import 'package:reactive_forms/reactive_forms.dart';
import 'package:studyu_designer_v2/common_views/form_table_layout.dart';
import 'package:studyu_designer_v2/features/design/shared/questionnaire/question/question_form_controller.dart';
import 'package:studyu_designer_v2/features/forms/form_validation.dart';
import 'package:studyu_designer_v2/localization/string_hardcoded.dart';

FormTableRow buildQuestionTextControlRow(
    {required QuestionFormViewModel formViewModel}) {
  return FormTableRow(
    control: formViewModel.questionTextControl,
    label: "Your question".hardcoded,
    labelHelpText:
    "Enter the question that the participant will be prompted with in the app"
        .hardcoded, // TODO export hint
    labelStyle: const TextStyle(fontWeight: FontWeight.bold),
    input: ReactiveTextField(
      formControl: formViewModel.questionTextControl,
      validationMessages: formViewModel.questionTextControl.validationMessages,
      minLines: 3,
      maxLines: 3,
      decoration: InputDecoration(
        hintText:
        "Enter the question you want to ask the participant".hardcoded,
        //helperText: "", // reserve space
      ),
    ),
  );
}
