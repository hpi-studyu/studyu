import 'package:flutter/material.dart';

enum UnsavedChangesAction { save, discard }

Future<UnsavedChangesAction?> showUnsavedChangesDialog(
  BuildContext context, {
  required String title,
  required String message,
  required String discardLabel,
  required String continueLabel,
  String? saveLabel,
}) => showDialog<UnsavedChangesAction>(
  context: context,
  builder: (dialogContext) => AlertDialog(
    title: Text(title),
    content: Text(message),
    actions: [
      TextButton(
        onPressed: () => Navigator.pop(dialogContext),
        child: Text(continueLabel),
      ),
      TextButton(
        onPressed: () =>
            Navigator.pop(dialogContext, UnsavedChangesAction.discard),
        child: Text(
          discardLabel,
          style: TextStyle(color: Theme.of(context).colorScheme.error),
        ),
      ),
      if (saveLabel != null)
        FilledButton(
          onPressed: () =>
              Navigator.pop(dialogContext, UnsavedChangesAction.save),
          child: Text(saveLabel),
        ),
    ],
  ),
);
