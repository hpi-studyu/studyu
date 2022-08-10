import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:reactive_forms/reactive_forms.dart';
import 'package:studyu_designer_v2/localization/string_hardcoded.dart';

typedef VoidAsyncValue = AsyncValue<void>;

extension AsyncValueUI on VoidAsyncValue {
  bool get isLoading => this is AsyncLoading<void>;

  void showResultUI(BuildContext context) => whenOrNull(
    error: (error, _) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $error'.hardcoded)),
      );
    },
  );
}

final authValidationMessages = {
  ValidationMessage.required: (error) => 'Field must not be empty',
  ValidationMessage.email: (error) => 'Must enter a valid email',
  ValidationMessage.mustMatch: (error) => 'Both passwords must match',
  ValidationMessage.minLength: (error) => 'Passwords have a minimum of ${(error as Map)['requiredLength']} characters',
};

/// Validates that control's value must be `true`
Map<String, dynamic>? _requiredTrue(AbstractControl<dynamic> control) {
  return control.isNotNull && control.value is bool && control.value == true
      ? null : {'requiredTrue': true};
}

ValidatorFunction _mustMatch(String controlName, String matchingControlName) {
  return (AbstractControl<dynamic> control) {
    final form = control as FormGroup;

    final formControl = form.control(controlName);
    final matchingFormControl = form.control(matchingControlName);

    if (formControl.value != matchingFormControl.value) {
      matchingFormControl.setErrors({'mustMatch': true});

      // force messages to show up as soon as possible
      matchingFormControl.markAsTouched();
    } else {
      matchingFormControl.removeError('mustMatch');
    }

    return null;
  };
}

// todo create keyvalue for email, password...
final authFormControlProvider = Provider.family.autoDispose<FormGroup?, String>((ref, fg) {
  switch(fg) {
    case('login'):
      return fb.group({
        'email': FormControl<String>(
            value: '', validators: [Validators.required, Validators.email]),
        'password': FormControl<String>(
            value: '', validators: [Validators.required, Validators.minLength(8)]),
        'rememberMe': FormControl<bool>(value: false),
      });
    case('signup'):
      return fb.group({
        'email': FormControl<String>(
            value: '', validators: [Validators.required, Validators.email]),
        'password': FormControl<String>(
            value: '', validators: [Validators.required, Validators.minLength(8)]),
        'passwordConfirmation': FormControl<String>(
            value: '', validators: [Validators.required]),
        'termsOfService': FormControl<bool>(
            value: false, validators: [Validators.required, _requiredTrue]),
      }, [
        _mustMatch('password', 'passwordConfirmation')
      ]);
    case('forgotPassword'):
      return fb.group({
        'email': FormControl<String>(
            value: '', validators: [Validators.required, Validators.email]),
      });
    case('recoverPassword'):
      return fb.group({
        'password': FormControl<String>(
            value: '', validators: [Validators.required, Validators.minLength(8)]),
        'passwordConfirmation': FormControl<String>(
            value: '', validators: [Validators.required]),
      }, [
        _mustMatch('password', 'passwordConfirmation')
      ]);
  }
  return null;
});