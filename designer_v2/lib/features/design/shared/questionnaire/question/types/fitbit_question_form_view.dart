import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:reactive_forms/reactive_forms.dart';
import 'package:studyu_core/core.dart';

import '../question_form_controller.dart';

class FitbitQuestionFormView extends ConsumerWidget {
  const FitbitQuestionFormView({required this.formViewModel, Key? key})
      : super(key: key);

  final QuestionFormViewModel formViewModel;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Fitbit Question Types',
        ),
        ReactiveFormField<Map<FitbitQuestionType, bool>,
            Map<FitbitQuestionType, bool>>(
          formControl: formViewModel.fitbitQuestionTypesControl,
          builder: (field) {
            final value = field.value ?? {};
            return Column(
              children: FitbitQuestionType.values.map((type) {
                return CheckboxListTile(
                  title: Text(type.name),
                  value: value[type] ?? false,
                  onChanged: (checked) {
                    field.didChange({
                      ...value,
                      type: checked ?? false,
                    });
                  },
                  controlAffinity: ListTileControlAffinity.leading,
                );
              }).toList(),
            );
          },
        ),
        if (formViewModel.fitbitQuestionTypesControl.hasErrors)
          Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: Text(
              'Please select at least one Fitbit question type.',
            ),
          ),
      ],
    );
  }
}
