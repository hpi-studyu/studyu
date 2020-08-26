import 'package:flutter/material.dart';

class ResultsDesigner extends StatefulWidget {
  @override
  _ResultsDesignerState createState() => _ResultsDesignerState();
}

class _ResultsDesignerState extends State<ResultsDesigner> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: SingleChildScrollView(
        child: Column(
          children: const <Widget>[],
        ),
      ),
    );
  }
}
