import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:studyou_core/models/models.dart';

import '../models/designer_state.dart';

class Publish extends StatefulWidget {
  @override
  _PublishState createState() => _PublishState();
}

class _PublishState extends State<Publish> {
  StudyBase _draftStudy;

  @override
  void initState() {
    super.initState();
    _draftStudy = context.read<DesignerState>().draftStudy;
  }

  void _publishStudy() {
    ParseStudy.fromBase(_draftStudy).save();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            Text(_draftStudy.title),
            RaisedButton.icon(onPressed: _publishStudy, icon: Icon(Icons.publish), label: Text('Publish study'))
          ],
        ),
      ),
    );
  }
}
