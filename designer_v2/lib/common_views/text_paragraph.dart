import 'package:flutter/material.dart';

class TextParagraph extends StatelessWidget {
  TextParagraph({this.text, this.style, this.selectable = true, this.span, super.key}) {
    if (text == null && span == null) {
      throw Exception("Either text or TextSpan has to be provided");
    }
  }

  final String? text;
  final TextStyle? style;
  final bool selectable;
  final List<TextSpan>? span;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textStyle = theme.textTheme.bodyMedium!.merge(style);

    if (!selectable) {
      if (span != null) {
        return RichText(text: TextSpan(children: span));
      }
      return Text(text!, style: textStyle);
    }
    if (span != null) {
      return SelectableText.rich(TextSpan(children: span), style: textStyle);
    }
    return SelectableText(text!, style: textStyle);
  }
}
