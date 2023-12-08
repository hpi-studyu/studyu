import 'package:flutter/material.dart';
import 'package:reactive_forms/reactive_forms.dart';
import 'package:reactive_range_slider/reactive_range_slider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:studyu_core/core.dart';
import 'package:studyu_designer_v2/common_views/text_paragraph.dart';
import 'package:studyu_designer_v2/features/design/shared/questionnaire/question/question_form_controller.dart';
import 'package:studyu_designer_v2/features/forms/form_control.dart';
import 'package:studyu_designer_v2/theme.dart';
import 'package:studyu_designer_v2/utils/extensions.dart';

import '../../../../../../common_views/form_table_layout.dart';

class FreeTextQuestionFormView extends ConsumerWidget {
  const FreeTextQuestionFormView({required this.formViewModel, super.key});

  final QuestionFormViewModel formViewModel;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final minLength = formViewModel.freeTextLengthControl.value!.start;
    final maxLength = formViewModel.freeTextLengthControl.value!.end;
    final type = formViewModel.freeTextTypeControl.value!.name;
    formViewModel.freeTextLengthControl.onChanged((_) => formViewModel.freeTextExampleTextControl.updateValueAndValidity());
    return Column(
      children: [
        generateRow(
            label: 'Allowed range of text length',
            labelHelpText: 'Specify the range of the text length that will be accepted a response is submitted.',
            input: ReactiveRangeSlider<RangeValues>(
              formControl: formViewModel.freeTextLengthControl,
              min: QuestionFormViewModel.kDefaultFreeTextMinLength.toDouble(),
              max: QuestionFormViewModel.kDefaultFreeTextMaxLength.toDouble(),
              divisions: QuestionFormViewModel.kDefaultFreeTextMaxLength
                  .toInt() -
                  QuestionFormViewModel.kDefaultFreeTextMinLength.toInt(),
              labelBuilder: (values) =>
                  RangeLabels(
                    values.start.round().toString(),
                    values.end.round().toString(),
                  ),
            )
        ),
        const SizedBox(height: 16.0),
        generateRow(
          label: 'Allowed input format',
          labelHelpText: 'Specify the format of the input that will be accepted when a response is submitted.',
          input: ReactiveDropdownField(
            formControl: formViewModel.freeTextTypeControl,
            items: FreeTextQuestionType.values.map((e) =>
                DropdownMenuItem(value: e, child: Text(e.name.capitalize())))
                .toList(),
            decoration: InputDecoration(
              helperText: generateLabelHelpTextMap[formViewModel
                  .freeTextTypeControl.value],
            ),
            onChanged: (_) {
              formViewModel.freeTextExampleTextControl.updateValueAndValidity();
            },
          ),
        ),
        const SizedBox(height: 16.0),
        // Show additional text field when custom is selected
        if (formViewModel.freeTextTypeControl.value ==
            FreeTextQuestionType.custom)
          Column(
            children: [
              generateRow(
                label: 'Regular expression',
                labelHelpText: 'Enter a regular expression to validate the input. Consult your favorite search engine to learn what regular expressions are and how to use them.',
                input: ReactiveTextField(
                  formControl: formViewModel.customRegexControl,
                  decoration: const InputDecoration(
                    helperText: "Example: Enter [a-zA-Z]+ to only allow letters.",
                    prefix: Text('^'),
                    suffix: Text('\$'),
                  ),
                  onChanged: (_) {
                    formViewModel.freeTextExampleTextControl.updateValueAndValidity();
                  },
                ),
              ),
              const SizedBox(height: 8.0),
              TextParagraph(
                text: 'Any input that does not match the expression will be rejected. The input length constraints specified above are still applied. A leading ^ and trailing \$ character will be added automatically.',
                style: ThemeConfig.bodyTextMuted(theme),
              )
            ],
          ),
        const SizedBox(height: 16.0),
        // generate line
        const Divider(thickness: 2.0),
        const SizedBox(height: 16.0),
        Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              generateRow(
                label: 'Example text field',
                labelHelpText: 'This is an example of the text field that will be shown to the participant. The length and input type constraints specified above will be applied.',
                input: Row(
                  children: [
                    Text(formViewModel.questionTextControl.value ?? 'Enter a survey title to see an example of the text field.'),
                    const SizedBox(width: 64.0),
                    Expanded(
                      child: ReactiveFormConsumer(
                          builder: (context, formGroup, child) {
                            final borderColor = (formViewModel.freeTextExampleTextControl.dirty) ? Colors.green : theme.inputDecorationTheme.enabledBorder?.borderSide.color ?? Colors.yellow;
                            return ReactiveTextField(
                              formControl: formViewModel.freeTextExampleTextControl,
                              decoration: InputDecoration(
                                helperText: (formViewModel.freeTextExampleTextControl.dirty && formViewModel.freeTextExampleTextControl.valid) ? 'Your example input is valid' : 'Perform a validation test by entering text here.',
                                focusedBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                    color: borderColor,
                                  ),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                    color: borderColor,
                                  ),
                                ),
                              ),
                              validationMessages: {
                                ValidationMessage.required: (error) => 'This field is required.',
                                ValidationMessage.minLength: (error) => 'The input must be at least $minLength characters long.',
                                ValidationMessage.maxLength: (error) => 'The input must be at most $maxLength characters long.',
                                ValidationMessage.pattern: (error) => 'The input must match the specified format.',
                                ValidationMessage.number: (error) => 'The input must be a number.',
                              }
                            );
                          }
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8.0),
              ReactiveFormConsumer(
                builder: (context, formGroup, child) {
                  return TextParagraph(
                    text: "${type.capitalize()} input with a character length range of $minLength to $maxLength will be accepted. "
                  );
                },
              ),
            ]
        ),
      ],
    );
  }

  get generateLabelHelpTextMap {
    return {
      FreeTextQuestionType
          .any: 'Any input.',
      FreeTextQuestionType
          .alphanumeric: 'Alphanumeric input includes words with letters, numbers, and special characters.',
      FreeTextQuestionType
          .numeric: 'Numeric input includes numbers without special characters.',
      FreeTextQuestionType
          .custom: 'Custom input allows you to specify a regular expression to validate the input.'
    };
  }

  Widget generateRow(
      {required String label, required String labelHelpText, required Widget input}) {
    return Row(
        children: [
          Flexible(
            flex: 5,
            child: FormTableLayout(
              rowLayout: FormTableRowLayout.vertical,
              rows: [
                FormTableRow(
                  label: label,
                  labelHelpText: labelHelpText,
                  input: input,
                ),
              ],
            ),
          ),
        ]
    );
  }
}
