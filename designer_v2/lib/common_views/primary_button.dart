import 'package:flutter/material.dart';

class PrimaryButton extends StatelessWidget {
  /// The text displayed as the button label
  final String text;
  /// The icon displayed to the left of the label
  final IconData icon;
  /// If true, a loading indicator is displayed instead of the text
  final bool isLoading;
  /// Callback to be called when the button is pressd
  final VoidCallback? onPressed;

  const PrimaryButton({
    required this.text,
    this.icon = Icons.add,
    this.isLoading = false,
    this.onPressed,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return ElevatedButton(
        onPressed: onPressed,
        child: isLoading
            ? const CircularProgressIndicator()
            : Text(text, textAlign: TextAlign.center),
      );
    }
    return ElevatedButton.icon(
      style: ElevatedButton.styleFrom(
          onPrimary: Theme.of(context).colorScheme.onPrimary,
          primary: Theme.of(context).colorScheme.primary,
        ).copyWith(elevation: ButtonStyleButton.allOrNull(0.0)),
      icon: Icon(icon),
      label: Text(text),
      onPressed: onPressed
    );
  }
}
