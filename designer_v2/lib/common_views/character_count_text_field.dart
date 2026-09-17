import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:reactive_forms/reactive_forms.dart';

class CharacterCountTextField extends StatelessWidget {
  const CharacterCountTextField({
    required this.formControl,
    required this.hintText,
    required this.maxLength,
    this.validationMessages,
    this.showErrors,
    this.helperTextBuilder,
    this.keyboardType,
    this.minLines = 1,
    this.maxLines = 1,
    super.key,
  });

  final FormControl<String> formControl;
  final String hintText;
  final int maxLength;
  final Map<String, ValidationMessageFunction>? validationMessages;
  final ShowErrorsFunction<String>? showErrors;
  final String? Function(AbstractControl<String> control)? helperTextBuilder;
  final TextInputType? keyboardType;
  final int minLines;
  final int maxLines;

  @override
  Widget build(BuildContext context) {
    return ReactiveValueListenableBuilder<String>(
      formControl: formControl,
      builder: (context, control, child) {
        return ReactiveTextField(
          formControl: formControl,
          decoration: InputDecoration(
            hintText: hintText,
            helperText: helperTextBuilder?.call(control),
          ),
          maxLength: maxLength,
          buildCounter:
              (
                context, {
                required currentLength,
                required isFocused,
                required maxLength,
              }) {
                if (!isFocused) {
                  return null;
                }
                return Text('$currentLength/$maxLength');
              },
          inputFormatters: [LengthLimitingTextInputFormatter(maxLength)],
          validationMessages: validationMessages,
          showErrors: showErrors,
          keyboardType: keyboardType,
          minLines: minLines,
          maxLines: maxLines,
        );
      },
    );
  }
}
