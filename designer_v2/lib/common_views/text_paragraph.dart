import 'package:flutter/material.dart';

class TextParagraph extends StatelessWidget {
  const TextParagraph({
    required this.text,
    this.style,
    this.selectable = true,
    Key? key
  }) : super(key: key);

  final String text;
  final TextStyle? style;
  final bool selectable;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textStyle = theme.textTheme.bodyText2!
        .merge(style);

    if (!selectable) {
      return Text(text, style: textStyle);
    }
    return SelectableText(text, style: textStyle);
  }
}
