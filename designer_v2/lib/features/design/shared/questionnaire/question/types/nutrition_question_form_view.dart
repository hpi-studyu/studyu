import 'package:flutter/material.dart';
import 'package:reactive_forms/reactive_forms.dart';
import 'package:studyu_designer_v2/features/design/shared/questionnaire/question/question_form_controller.dart';

class NutritionQuestionFormView extends StatelessWidget {
  const NutritionQuestionFormView({required this.formViewModel, super.key});

  final QuestionFormViewModel formViewModel;

  @override
  Widget build(BuildContext context) {
    return ReactiveFormConsumer(
      builder: (context, form, child) {
        // Nutrition question currently has no specific configuration options
        // beyond the standard question text and info text.
        return const SizedBox.shrink();
      },
    );
  }
}
