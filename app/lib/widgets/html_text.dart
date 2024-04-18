import 'package:flutter/material.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';

class HtmlText extends StatelessWidget {
  const HtmlText(
    this.text, {
    this.style,
    this.centered = false,
    super.key,
  });

  final String? text;
  final TextStyle? style;
  final bool centered;

  @override
  Widget build(BuildContext context) {
    Widget htmlWidget = HtmlWidget(
      text ?? '',
      textStyle: style,
      // these callbacks are called when a complicated element is loading
      // or failed to render allowing the app to render progress indicator
      // and fallback widget
      onErrorBuilder: (context, element, error) => Text('$element Error: $error'),
      onLoadingBuilder: (context, element, loadingProgress) => const CircularProgressIndicator(),
    );

    return SingleChildScrollView(
      child: SizedBox(
        width: double.maxFinite,
        child: centered ? Center(child: htmlWidget) : htmlWidget,
      ),
    );
  }
}
