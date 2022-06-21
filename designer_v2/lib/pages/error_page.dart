import 'package:studyu_designer_v2/localization/string_hardcoded.dart';
import 'package:flutter/material.dart';

class ErrorPage extends StatefulWidget {
  final String error;

  const ErrorPage({Key? key, required this.error}) : super(key: key);

  @override
  _ErrorPageState createState() => _ErrorPageState();
}

class _ErrorPageState extends State<ErrorPage> {
  @override
  Widget build(BuildContext context) {
    print(widget.error);
    return Container(
        child: Align(
            alignment: Alignment.center,
            child: Text('Oops something went wrong!'.hardcoded)
        )
    );
  }
}