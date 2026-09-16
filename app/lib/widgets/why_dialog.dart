import 'package:flutter/material.dart';
import 'package:studyu_app/l10n/app_localizations.dart';

class WhyDialog extends StatelessWidget {
  final String content;

  const WhyDialog({required this.content, super.key});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      contentPadding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
      content: Text(content),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(AppLocalizations.of(context)!.close),
        ),
      ],
    );
  }
}
