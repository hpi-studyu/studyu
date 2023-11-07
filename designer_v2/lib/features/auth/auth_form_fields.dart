import 'package:flutter/material.dart';
import 'package:reactive_forms/reactive_forms.dart';
import 'package:studyu_designer_v2/common_views/form_table_layout.dart';
import 'package:studyu_designer_v2/localization/app_translation.dart';

class EmailTextField extends StatefulWidget {
  EmailTextField({
    labelText,
    this.formControlName,
    this.formControl,
    hintText,
    super.key,
  })  : assert((formControlName != null && formControl == null) || (formControlName == null && formControl != null),
            "Must provide either formControlName or formControl"),
        labelText = labelText ?? tr.form_field_email,
        hintText = hintText ?? tr.form_field_email_hint;

  final String labelText;
  final String? hintText;
  final String? formControlName;
  final FormControl? formControl;

  @override
  State<EmailTextField> createState() => _EmailTextFieldState();
}

class _EmailTextFieldState extends State<EmailTextField> {
  @override
  Widget build(BuildContext context) {
    return FormTableLayout(
      rowLayout: FormTableRowLayout.vertical,
      rows: [
        FormTableRow(
          labelStyle: const TextStyle(fontWeight: FontWeight.bold),
          input: ReactiveTextField(
            formControl: widget.formControl,
            formControlName: widget.formControlName,
            decoration: InputDecoration(
              labelText: widget.labelText,
              hintText: widget.hintText,
            ),
          ),
        )
      ],
    );
  }
}

class PasswordTextField extends StatefulWidget {
  PasswordTextField({
    labelText,
    this.formControlName,
    this.formControl,
    hintText,
    super.key,
  })  : assert((formControlName != null && formControl == null) || (formControlName == null && formControl != null),
            "Must provide either formControlName or formControl"),
        labelText = labelText ?? tr.form_field_password,
        hintText = hintText ?? tr.form_field_password_hint;

  final String labelText;
  final String? hintText;
  final String? formControlName;
  final FormControl? formControl;

  @override
  State<PasswordTextField> createState() => _PasswordTextFieldState();
}

class _PasswordTextFieldState extends State<PasswordTextField> {
  late bool passwordVisibility = false;

  @override
  Widget build(BuildContext context) {
    return FormTableLayout(
      rowLayout: FormTableRowLayout.vertical,
      rows: [
        FormTableRow(
            input: ReactiveTextField(
          formControl: widget.formControl,
          formControlName: widget.formControlName,
          obscureText: !passwordVisibility,
          decoration: InputDecoration(
            labelText: widget.labelText,
            hintText: widget.hintText,
            suffixIcon: InkWell(
              onTap: () => setState(
                () => passwordVisibility = !passwordVisibility,
              ),
              focusNode: FocusNode(skipTraversal: true),
              child: Icon(
                passwordVisibility ? Icons.visibility_outlined : Icons.visibility_off_outlined,
              ),
            ),
          ),
        ))
      ],
    );
  }
}
