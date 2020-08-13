import 'package:flutter/material.dart';

class ReportDesigner extends StatefulWidget {
  @override
  _ReportDesignerState createState() => _ReportDesignerState();
}

class _ReportDesignerState extends State<ReportDesigner> {
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
