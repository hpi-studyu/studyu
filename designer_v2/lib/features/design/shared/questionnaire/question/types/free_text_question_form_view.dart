import 'package:flutter/material.dart';
import 'package:reactive_forms/reactive_forms.dart';
import 'package:reactive_range_slider/reactive_range_slider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:studyu_core/core.dart';
import 'package:studyu_designer_v2/common_views/form_table_layout.dart';
import 'package:studyu_designer_v2/common_views/text_paragraph.dart';
import 'package:studyu_designer_v2/features/design/shared/questionnaire/question/question_form_controller.dart';
import 'package:studyu_designer_v2/features/design/shared/questionnaire/question/types/question_type.dart';
import 'package:studyu_designer_v2/features/forms/form_control.dart';
import 'package:studyu_designer_v2/localization/app_translation.dart';
import 'package:studyu_designer_v2/theme.dart';

class FreeTextQuestionFormView extends ConsumerWidget {
  const FreeTextQuestionFormView({required this.formViewModel, super.key});

  final QuestionFormViewModel formViewModel;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final minLength = formViewModel.freeTextLengthControl.value!.start.toInt();
    final maxLength = formViewModel.freeTextLengthControl.value!.end.toInt();
    final type = formViewModel.freeTextTypeControl.value!.string;
    formViewModel.freeTextLengthControl
        .onChanged((_) => formViewModel.freeTextExampleTextControl.updateValueAndValidity());

    return Column(
      children: [
        generateRow(
            label: tr.free_text_range_label,
            labelHelpText: tr.free_text_range_label_helper,
            input: disableOnReadonly(
              child: SliderTheme(
                  data: Theme.of(context).sliderTheme.copyWith(
                      rangeThumbShape: IndicatorRangeSliderThumbShape(minLength.toInt(), maxLength.toInt()),
                      showValueIndicator: ShowValueIndicator.never),
                  child: ReactiveRangeSlider<RangeValues>(
                    formControl: formViewModel.freeTextLengthControl,
                    min: QuestionFormViewModel.kDefaultFreeTextMinLength.toDouble(),
                    max: QuestionFormViewModel.kDefaultFreeTextMaxLength.toDouble(),
                    divisions: QuestionFormViewModel.kDefaultFreeTextMaxLength.toInt() -
                        QuestionFormViewModel.kDefaultFreeTextMinLength.toInt(),
                    labelBuilder: (values) => RangeLabels(
                      values.start.round().toString(),
                      values.end.round().toString(),
                    ),
                  )),
            )),
        const SizedBox(height: 16.0),
        generateRow(
          label: tr.free_text_type_label,
          labelHelpText: tr.free_text_type_label_helper,
          input: ReactiveDropdownField(
            formControl: formViewModel.freeTextTypeControl,
            items: FreeTextQuestionType.values.map((e) => DropdownMenuItem(value: e, child: Text(e.string))).toList(),
            decoration: InputDecoration(
              helperText: generateLabelHelpTextMap[formViewModel.freeTextTypeControl.value],
            ),
            onChanged: (_) {
              formViewModel.freeTextExampleTextControl.updateValueAndValidity();
            },
          ),
        ),
        const SizedBox(height: 16.0),
        // Show additional text field when custom is selected
        if (formViewModel.freeTextTypeControl.value == FreeTextQuestionType.custom)
          Column(
            children: [
              generateRow(
                label: tr.free_text_type_custom_label,
                labelHelpText: tr.free_text_type_custom_label_helper,
                input: ReactiveTextField(
                  formControl: formViewModel.customRegexControl,
                  decoration: InputDecoration(
                    helperText: tr.free_text_type_custom_helper,
                    prefix: const Text('^'),
                    suffix: const Text('\$'),
                  ),
                  onChanged: (_) {
                    formViewModel.freeTextExampleTextControl.updateValueAndValidity();
                  },
                ),
              ),
              const SizedBox(height: 8.0),
              TextParagraph(
                text: tr.free_text_type_custom_explanation,
                style: ThemeConfig.bodyTextMuted(theme),
              )
            ],
          ),
        const SizedBox(height: 16.0),
        // generate line
        const Divider(thickness: 2.0),
        const SizedBox(height: 16.0),
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          generateRow(
            label: tr.free_text_example_label,
            labelHelpText: tr.free_text_example_label_helper,
            input: Row(
              children: [
                Expanded(
                  child: ReactiveValueListenableBuilder(
                      formControl: formViewModel.freeTextExampleTextControl,
                      builder: (context, formControl, child) {
                        final borderColor = (formControl.dirty)
                            ? Colors.green
                            : theme.inputDecorationTheme.enabledBorder?.borderSide.color ?? Colors.yellow;
                        return ReactiveTextField(
                            formControl: formViewModel.freeTextExampleTextControl,
                            maxLines: null,
                            decoration: InputDecoration(
                              helperText: (formControl.dirty && formControl.valid)
                                  ? tr.free_text_example_valid
                                  : tr.free_text_example_default_helper,
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
                            showErrors: (control) => control.invalid && control.dirty,
                            validationMessages: {
                              ValidationMessage.minLength: (error) => tr.free_text_validation_min_length(minLength),
                              ValidationMessage.maxLength: (error) => tr.free_text_validation_max_length(maxLength),
                              ValidationMessage.pattern: (error) => tr.free_text_validation_pattern,
                              ValidationMessage.number: (error) => tr.free_text_validation_number,
                            });
                      }),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16.0),
          ReactiveFormConsumer(
            builder: (context, formGroup, child) {
              return TextParagraph(text: tr.free_text_example_explanation(type, minLength, maxLength));
            },
          ),
        ]),
      ],
    );
  }

  Widget disableOnReadonly({required Widget child}) {
    if (formViewModel.isReadonly) {
      return AbsorbPointer(child: child);
    } else {
      return child;
    }
  }

  get generateLabelHelpTextMap {
    return {
      FreeTextQuestionType.any: tr.free_text_question_type_any_explanation,
      FreeTextQuestionType.alphanumeric: tr.free_text_question_type_alphanumeric_explanation,
      FreeTextQuestionType.numeric: tr.free_text_question_type_numeric_explanation,
      FreeTextQuestionType.custom: tr.free_text_question_type_custom_explanation,
    };
  }

  Widget generateRow({required String label, required String labelHelpText, required Widget input}) {
    return Row(children: [
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
    ]);
  }
}

// Workaround to always show the value indicator for the range slider
// Source: https://github.com/flutter/flutter/issues/34704#issuecomment-1338849463
class IndicatorRangeSliderThumbShape<T> extends RangeSliderThumbShape {
  IndicatorRangeSliderThumbShape(this.start, this.end);

  @override
  Size getPreferredSize(bool isEnabled, bool isDiscrete) {
    return const Size(15, 40);
  }

  T start;
  T end;
  late TextPainter labelTextPainter = TextPainter()..textDirection = TextDirection.ltr;

  @override
  void paint(
    PaintingContext context,
    Offset center, {
    required Animation<double> activationAnimation,
    required Animation<double> enableAnimation,
    bool? isDiscrete,
    bool? isEnabled,
    bool? isOnTop,
    TextDirection? textDirection,
    required SliderThemeData sliderTheme,
    Thumb? thumb,
    bool? isPressed,
  }) {
    final Canvas canvas = context.canvas;
    final Paint strokePaint = Paint()
      ..color = sliderTheme.thumbColor ?? Colors.yellow
      ..strokeWidth = 3.0
      ..style = PaintingStyle.stroke;
    canvas.drawCircle(center, 7.5, Paint()..color = Colors.white);
    canvas.drawCircle(center, 7.5, strokePaint);
    if (thumb == null) {
      return;
    }
    final value = thumb == Thumb.start ? start : end;
    labelTextPainter.text = TextSpan(text: value.toString());
    labelTextPainter.layout();
    labelTextPainter.paint(canvas, center.translate(-labelTextPainter.width / 2, (labelTextPainter.height / 2) + 4));
  }
}
