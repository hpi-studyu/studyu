import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:studyu_designer_v2/features/design/shared/questionnaire/question/question_form_controller.dart';

/// Medication questions have no designer-configurable response options.
class MedicationQuestionFormView extends ConsumerWidget {
  const MedicationQuestionFormView({required this.formViewModel, super.key});

  final QuestionFormViewModel formViewModel;

  @override
  Widget build(BuildContext context, WidgetRef ref) => const SizedBox.shrink();
}
