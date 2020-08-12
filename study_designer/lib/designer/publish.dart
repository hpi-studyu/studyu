import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/designer_state.dart';

class Publish extends StatefulWidget {
  @override
  _PublishState createState() => _PublishState();
}

class _PublishState extends State<Publish> {
  LocalStudy _draftStudy;

  @override
  void initState() {
    super.initState();
    _draftStudy = context.read<DesignerModel>().draftStudy;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: SingleChildScrollView(
        child: Column(
          children: <Widget>[Text(_draftStudy.title)],
        ),
      ),
    );
  }
}
