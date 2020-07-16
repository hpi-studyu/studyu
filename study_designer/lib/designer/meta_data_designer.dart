import 'package:flutter/material.dart';

class MetaDataDesigner extends StatefulWidget {
  @override
  _MetaDataDesignerState createState() => _MetaDataDesignerState();
}

class _MetaDataDesignerState extends State<MetaDataDesigner> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.all(16),
      child: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            RaisedButton(
              onPressed: () {
                showDialog(
                    context: context,
                    builder: (context) {
                      return AlertDialog(content: Text('hi'));
                    });
              },
              child: Text('Open Popup'),
            ),
          ],
        ),
      ),
    );
  }
}
