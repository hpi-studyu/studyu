import 'package:flutter/material.dart';
import 'package:pointer_interceptor/pointer_interceptor.dart';
import 'package:studyu_designer_v2/common_views/dialog.dart';
import 'package:studyu_designer_v2/common_views/primary_button.dart';
import 'package:studyu_designer_v2/common_views/secondary_button.dart';
import 'package:studyu_designer_v2/common_views/text_paragraph.dart';

class ConfirmationDialogAction {
  const ConfirmationDialogAction({
    required this.label,
    required this.onPressed,
    this.isDestructive = false,
  });

  final String label;
  final VoidCallback onPressed;
  final bool isDestructive;
}

class StandardConfirmationDialog extends StatelessWidget {
  const StandardConfirmationDialog({
    required this.title,
    required this.actions,
    this.message,
    this.customContent,
    this.icon,
    super.key,
  });

  final String title;
  final String? message;
  final Widget? customContent;
  final IconData? icon;
  final List<ConfirmationDialogAction> actions;

  bool get isDestructive => actions.any((action) => action.isDestructive);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final severityColor = theme.colorScheme.error;

    return PointerInterceptor(
      child: StandardDialog(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(icon, color: isDestructive ? severityColor : null),
              const SizedBox(width: 8),
            ],
            Flexible(
              child: SelectableText(
                title,
                style: theme.textTheme.displaySmall?.copyWith(
                  fontWeight: FontWeight.normal,
                  color: theme.colorScheme.onPrimaryContainer,
                ),
              ),
            ),
          ],
        ),
        body:
            customContent ??
            (message == null
                ? const SizedBox.shrink()
                : TextParagraph(text: message)),
        actionButtons: [
          for (final (index, action) in actions.indexed)
            if (action.isDestructive)
              PrimaryButton(
                onPressed: action.onPressed,
                text: action.label,
                icon: null,
                backgroundColor: severityColor,
                foregroundColor: Colors.white,
                minimumSize: const Size(120, 40),
              )
            else if (isDestructive)
              SecondaryButton(
                onPressed: action.onPressed,
                text: action.label,
                icon: null,
                minimumSize: const Size(120, 40),
              )
            else if (index == 0)
              PrimaryButton(
                onPressed: action.onPressed,
                text: action.label,
                icon: null,
                minimumSize: const Size(120, 40),
              )
            else
              SecondaryButton(
                onPressed: action.onPressed,
                text: action.label,
                icon: null,
                minimumSize: const Size(120, 40),
              ),
        ],
        maxWidth: 500,
        minHeight: 0,
      ),
    );
  }
}
