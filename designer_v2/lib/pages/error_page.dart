import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';

class ErrorPage extends StatefulWidget {
  final String error;

  const ErrorPage({Key? key, required this.error}) : super(key: key);

  @override
  ErrorPageState createState() => ErrorPageState();
}

class ErrorPageState extends State<ErrorPage> {
  @override
  Widget build(BuildContext context) {
    if (kDebugMode) {
      print(widget.error);
    }
    return const Align(
        alignment: Alignment.center,
        child: Text('Oops something went wrong!'));
  }
}
