import 'package:flutter/material.dart';

class ScheduleDesigner extends StatefulWidget {
  @override
  _ScheduleDesignerState createState() => _ScheduleDesignerState();
}

class _ScheduleDesignerState extends State<ScheduleDesigner> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.all(16),
      child: SingleChildScrollView(
        child: Column(
          children: <Widget>[],
        ),
      ),
    );
  }
}
