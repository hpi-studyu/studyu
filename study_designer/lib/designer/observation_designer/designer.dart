import 'package:flutter/material.dart';

class ObservationDesigner extends StatefulWidget {
  @override
  _ObservationDesignerState createState() => _ObservationDesignerState();
}

class _ObservationDesignerState extends State<ObservationDesigner> {
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
