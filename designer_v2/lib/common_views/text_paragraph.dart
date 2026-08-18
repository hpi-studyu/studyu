import 'package:flutter/material.dart';

class TextParagraph extends StatelessWidget {
  TextParagraph({
    this.text,
    this.style,
    this.textAlign,
    this.selectable = true,
    this.span,
    super.key,
  }) {
    if (text == null && span == null) {
      throw Exception("Either text or TextSpan has to be provided");
    }
  }

  final String? text;
  final TextStyle? style;
  final TextAlign? textAlign;
  final bool selectable;
  final List<TextSpan>? span;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textStyle = theme.textTheme.bodyMedium!.merge(style);

    if (!selectable) {
      if (span != null) {
        return RichText(
          text: TextSpan(children: span),
          textAlign: textAlign ?? TextAlign.start,
        );
      }
      return Text(text!, style: textStyle, textAlign: textAlign);
    }
    if (span != null) {
      return SelectableText.rich(
        TextSpan(children: span),
        style: textStyle,
        textAlign: textAlign ?? TextAlign.start,
      );
    }
    return SelectableText(text!, style: textStyle, textAlign: textAlign);
  }
}
