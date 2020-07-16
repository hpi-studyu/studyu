import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:studyou_core/models/models.dart';

import '../models/desinger_state.dart';

class MetaDataDesigner extends StatefulWidget {
  @override
  _MetaDataDesignerState createState() => _MetaDataDesignerState();
}

class _MetaDataDesignerState extends State<MetaDataDesigner> {
  Study _draftStudy;

  @override
  void initState() {
    super.initState();
    _draftStudy = context.read<DesignerModel>().draftStudy;
  }

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
