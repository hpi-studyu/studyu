import 'package:flutter/material.dart';

class AuthInlinePromptAction extends StatelessWidget {
  const AuthInlinePromptAction({
    required this.promptText,
    required this.actionText,
    required this.onPressed,
    super.key,
  });

  final String promptText;
  final String actionText;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Wrap(
      crossAxisAlignment: WrapCrossAlignment.center,
      spacing: 2.0,
      runSpacing: 2.0,
      children: [
        Text(promptText, style: theme.textTheme.bodyMedium),
        TextButton(
          onPressed: onPressed,
          style: TextButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 4.0),
            minimumSize: Size.zero,
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            visualDensity: VisualDensity.compact,
          ),
          child: Text(actionText),
        ),
      ],
    );
  }
}
