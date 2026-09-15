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

  static const _narrowLayoutBreakpoint = 360.0;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final prompt = Text(promptText, style: theme.textTheme.bodyMedium);
    final action = TextButton(
      onPressed: onPressed,
      style: TextButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 4.0),
        minimumSize: const Size(48.0, 48.0),
        tapTargetSize: MaterialTapTargetSize.padded,
        visualDensity: VisualDensity.standard,
      ),
      child: Text(actionText),
    );

    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < _narrowLayoutBreakpoint) {
          return Wrap(
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 2.0,
            runSpacing: 2.0,
            children: [prompt, action],
          );
        }

        return Row(
          children: [
            Expanded(child: prompt),
            action,
          ],
        );
      },
    );
  }
}
