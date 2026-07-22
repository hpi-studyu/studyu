import 'package:flutter/material.dart';

class StudyOnboardingDescription extends StatelessWidget {
  final String text;
  final String? actionLabel;
  final VoidCallback? onAction;
  final String? supportingText;

  const StudyOnboardingDescription({
    required this.text,
    this.actionLabel,
    this.onAction,
    this.supportingText,
    super.key,
  }) : assert(
         (actionLabel == null) == (onAction == null),
         'actionLabel and onAction must be provided together',
       );

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primaryStyle = theme.textTheme.titleMedium!;

    return SizedBox(
      width: double.infinity,
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Column(
          children: [
            Text.rich(
              TextSpan(
                style: primaryStyle,
                children: [
                  TextSpan(text: text),
                  if (actionLabel != null) ...[
                    const TextSpan(text: ' '),
                    WidgetSpan(
                      alignment: PlaceholderAlignment.baseline,
                      baseline: TextBaseline.alphabetic,
                      child: TextButton(
                        onPressed: onAction,
                        style: TextButton.styleFrom(
                          padding: EdgeInsets.zero,
                          minimumSize: const Size(48, 48),
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          textStyle: primaryStyle,
                        ),
                        child: Text(actionLabel!),
                      ),
                    ),
                  ],
                ],
              ),
              textAlign: TextAlign.center,
            ),
            if (supportingText != null) ...[
              const SizedBox(height: 8),
              Text(
                supportingText!,
                style: theme.textTheme.bodyMedium!.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
