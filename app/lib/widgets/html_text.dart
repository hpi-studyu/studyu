import 'package:flutter/material.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';

class HtmlText extends StatelessWidget{
  const HtmlText(this.text, {this.style, Key key,}) : super(key: key);

  final String text;
  final TextStyle style;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: SizedBox(
        width: double.maxFinite,
        child: HtmlWidget(text ?? '', textStyle: style,),
      ),
    );
  }
}
