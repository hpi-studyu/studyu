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
      children: [
        ...FitbitQuestionType.values.map((type) {
          return ReactiveCheckboxListTile(
            formControl: formViewModel.fitbitTypeControls[type],
            title: Text(type.name),
            onChanged: (value) {
              final currentTypes =
                  formViewModel.fitbitQuestionTypesControl.value ??
                      <FitbitQuestionType>[];

              final FitbitQuestionType typeEnum = FitbitQuestionType.values
                  .firstWhere((element) => element.name == type.name);
              if (value.value == true) {
                currentTypes.add(typeEnum);
              } else {
                currentTypes.remove(typeEnum);
              }

              formViewModel.fitbitQuestionTypesControl
                  .updateValue(currentTypes);
            },
          );
        })
      ],
    );
  }
}
