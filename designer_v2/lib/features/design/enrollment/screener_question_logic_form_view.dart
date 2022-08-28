import 'package:flutter/material.dart';
import 'package:reactive_forms/reactive_forms.dart';
import 'package:studyu_designer_v2/common_views/form_consumer_widget.dart';
import 'package:studyu_designer_v2/common_views/under_construction.dart';
import 'package:studyu_designer_v2/features/design/shared/questionnaire/question/question_form_controller.dart';

class ScreenerQuestionLogicFormView extends FormConsumerWidget {
  const ScreenerQuestionLogicFormView({required this.formViewModel, Key? key})
      : super(key: key);

  final QuestionFormViewModel formViewModel;

  @override
  Widget build(BuildContext context, FormGroup form) {
    return UnderConstruction();
  }
}
