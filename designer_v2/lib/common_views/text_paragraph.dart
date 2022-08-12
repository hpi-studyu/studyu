import 'package:flutter/material.dart';

class TextParagraph extends StatelessWidget {
  const TextParagraph({required this.text, Key? key}) : super(key: key);

  final String text;

  @override
  Widget build(BuildContext context) {
    return SelectableText(
      text,
      style: Theme.of(context).textTheme.bodyText2!.copyWith(
        height: 1.35,
        color: Theme.of(context).colorScheme.onSurface.withOpacity(0.8)),
    );
  }
}
