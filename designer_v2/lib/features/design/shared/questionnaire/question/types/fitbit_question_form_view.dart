import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:reactive_forms/reactive_forms.dart';
import 'package:studyu_core/core.dart';

import 'package:studyu_designer_v2/features/design/shared/questionnaire/question/question_form_controller.dart';

class FitbitQuestionFormView extends ConsumerWidget {
  const FitbitQuestionFormView({required this.formViewModel, super.key});

  final QuestionFormViewModel formViewModel;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Fitbit Question Types',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        ReactiveFormArray(
          formArray: formViewModel.fitbitResponseOptionsArray,
          builder: (context, formArray, child) {
            if (formArray.controls.isEmpty) {
              return const Text('No Fitbit question types available.');
            }

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: FitbitQuestionType.values.asMap().entries.map((entry) {
                final index = entry.key;
                final type = entry.value;

                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4.0),
                  child: Row(
                    children: [
                      ReactiveCheckbox(
                        formControl: formArray.controls[index]
                            as FormControl<bool>, // Cast control
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          type.name,
                          style: const TextStyle(fontSize: 14),
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            );
          },
        ),
      ],
    );
  }
}
