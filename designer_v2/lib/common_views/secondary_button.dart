import 'package:flutter/material.dart';
import 'package:studyu_designer_v2/common_views/primary_button.dart';

/// See also: [PrimaryButton]
class SecondaryButton extends StatelessWidget {
  /// The text displayed as the button label
  final String text;

  /// The icon displayed to the left of the label
  final IconData? icon;

  /// If true, a loading indicator is displayed instead of the text
  final bool isLoading;

  /// Callback to be called when the button is pressed
  final VoidCallback? onPressed;

  const SecondaryButton({
    required this.text,
    this.icon = Icons.add,
    this.isLoading = false,
    this.onPressed,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final secondaryStyle = OutlinedButton.styleFrom(
      side: BorderSide(color: theme.colorScheme.primary),
    );

    if (icon != null) {
      return OutlinedButton.icon(
        style: secondaryStyle,
        onPressed: onPressed,
        icon: Icon(icon),
        label: Text(text),
      );
    }
    return OutlinedButton(
      style: secondaryStyle,
      onPressed: onPressed,
      child: isLoading ? const CircularProgressIndicator() : Text(text, textAlign: TextAlign.center),
    );
  }
}
