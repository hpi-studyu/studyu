import 'package:flutter/material.dart';

class ConsentDesigner extends StatefulWidget {
  @override
  _ConsentDesignerState createState() => _ConsentDesignerState();
}

class _ConsentDesignerState extends State<ConsentDesigner> {
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
