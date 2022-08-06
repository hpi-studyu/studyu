import 'package:flutter/material.dart';

class PrimaryButton extends StatelessWidget {
  /// The text displayed as the button label
  final String text;
  /// If true, a loading indicator is displayed instead of the text
  final bool isLoading;
  /// Callback to be called when the button is pressed
  final VoidCallback? onPressed;

  const PrimaryButton({
    Key? key, required this.text, this.isLoading = false, this.onPressed
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
        onPressed: onPressed,
        child: isLoading
            ? const CircularProgressIndicator()
            : Text(text, textAlign: TextAlign.center),
      );
  }
}
