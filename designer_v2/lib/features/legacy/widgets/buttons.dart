import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class DeleteButton extends StatelessWidget {
  final void Function() onPressed;

  const DeleteButton({Key? key, required this.onPressed}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextButton.icon(
      style: TextButton.styleFrom(primary: Colors.red),
      icon: const Icon(Icons.delete),
      onPressed: onPressed,
      label: Text(AppLocalizations.of(context)!.delete),
    );
  }
}
