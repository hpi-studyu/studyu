import 'package:flutter/material.dart';

/// See also: [SecondaryButton]
class PrimaryButton extends StatelessWidget {
  /// The text displayed as the button label
  final String text;
  /// The icon displayed to the left of the label
  final IconData? icon;
  /// If true, a loading indicator is displayed instead of the text
  final bool isLoading;
  /// Callback to be called when the button is pressd
  final VoidCallback? onPressed;

  final String tooltip;
  final String tooltipDisabled;

  const PrimaryButton({
    required this.text,
    this.icon = Icons.add,
    this.tooltip = "",
    this.tooltipDisabled = "",
    this.isLoading = false,
    this.onPressed,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final primaryStyle = ElevatedButton.styleFrom(
      onPrimary: Theme.of(context).colorScheme.onPrimary,
      primary: Theme.of(context).colorScheme.primary,
    ).copyWith(elevation: ButtonStyleButton.allOrNull(0.0));

    if (icon != null) {
      return Tooltip(
        message: (onPressed != null) ? tooltip : tooltipDisabled,
        child: ElevatedButton.icon(
          style: primaryStyle,
          onPressed: onPressed,
          icon: Icon(icon),
          label: Text(text),
        )
      );
    }
    return Tooltip(
      message: (onPressed != null) ? tooltip : tooltipDisabled,
      child: ElevatedButton(
        style: primaryStyle,
        onPressed: onPressed,
        child: isLoading
            ? const CircularProgressIndicator()
            : Text(text, textAlign: TextAlign.center),
      )
    );
  }
}
