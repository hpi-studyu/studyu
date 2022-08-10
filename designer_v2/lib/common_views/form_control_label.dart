import 'package:flutter/material.dart';
import 'package:reactive_forms/reactive_forms.dart';
import 'package:studyu_designer_v2/common_views/mouse_events.dart';

class FormControlLabel extends StatelessWidget {
  const FormControlLabel({
    required this.formControl,
    required this.text,
    this.textStyle,
    this.isClickable = true,
    Key? key
  }) : super(key: key);

  final AbstractControl<dynamic> formControl;
  final String text;
  final bool isClickable;
  final TextStyle? textStyle;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return MouseEventsRegion(
      builder: (context, states) {
        return Text(
            text,
            style: theme.textTheme.bodyText2!.copyWith(
              fontSize: theme.textTheme.bodyText2!.fontSize! * 0.9,
              height: theme.textTheme.labelMedium!.height,
            ).merge(textStyle),
        );
      },
      onTap: (!isClickable) ? null : () {
        if (formControl is AbstractControl<bool>) {
          // Auto-toggle boolean controls
          formControl.value = (formControl.value != null)
              ? !(formControl.value!) : true;
          formControl.markAsDirty();
        } else {
          // Otherwise just focus the control
          formControl.focus();
        }
      },
    );
  }
}
