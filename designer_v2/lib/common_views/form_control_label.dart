import 'package:flutter/material.dart';
import 'package:reactive_forms/reactive_forms.dart';
import 'package:studyu_designer_v2/common_views/mouse_events.dart';

typedef FormControlVoidCallback<T> = void Function(AbstractControl<T> formControl);

class FormControlLabel extends StatelessWidget {
  const FormControlLabel(
      {required this.formControl,
      required this.text,
      this.textStyle,
      this.isClickable = true,
      this.onClick,
      super.key});

  final AbstractControl<dynamic> formControl;
  final String text;
  final bool isClickable;
  final TextStyle? textStyle;
  final FormControlVoidCallback? onClick;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final stateColorStyle = (formControl.disabled) ? TextStyle(color: theme.disabledColor) : null;

    return MouseEventsRegion(
      builder: (context, states) {
        return Text(
          text,
          style: theme.textTheme.bodySmall?.merge(textStyle).merge(stateColorStyle),
          overflow: TextOverflow.clip,
        );
      },
      onTap: (!isClickable || formControl.disabled)
          ? null
          : () {
              if (onClick != null) {
                onClick!(formControl);
              } else {
                if (formControl is AbstractControl<bool>) {
                  // Auto-toggle boolean controls
                  formControl.value = (formControl.value != null) ? !(formControl.value!) : true;
                  formControl.markAsDirty();
                } else {
                  // Otherwise just focus the control
                  formControl.focus();
                }
              }
            },
    );
  }
}
