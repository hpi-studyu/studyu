import 'package:clipboard/clipboard.dart';
import 'package:flutter/material.dart';
import 'package:flutter_json_widget/flutter_json_widget.dart';
import 'package:pretty_json/pretty_json.dart';
import 'package:provider/provider.dart';
import 'package:studyou_core/models/models.dart';

import '../models/designer_state.dart';

class Save extends StatefulWidget {
  @override
  _SaveState createState() => _SaveState();
}

class _SaveState extends State<Save> {
  StudyBase _draftStudy;

  @override
  void initState() {
    super.initState();
    _draftStudy = context.read<DesignerState>().draftStudy;
  }

  void _publishStudy() {
    ParseStudy.fromBase(_draftStudy).save();
  }

  void _saveDraft() {
    ParseStudy.fromBase(_draftStudy).save();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.all(32),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                OutlineButton.icon(
                    onPressed: _saveDraft,
                    icon: Icon(Icons.save),
                    label: Text('Save draft', style: TextStyle(fontSize: 30))),
                SizedBox(width: 16),
                OutlineButton.icon(
                    onPressed: _publishStudy,
                    icon: Icon(Icons.publish),
                    label: Text('Publish study', style: TextStyle(fontSize: 30))),
              ],
            ),
            SizedBox(height: 16),
            Row(
              children: [
                Text('Resulting Study model in JSON format', style: theme.textTheme.headline6),
                SizedBox(width: 8),
                OutlineButton.icon(
                    onPressed: () async {
                      await FlutterClipboard.copy(prettyJson(_draftStudy.toJson()));
                      Scaffold.of(context).showSnackBar(SnackBar(content: Text('Copied JSON')));
                    },
                    icon: Icon(Icons.copy),
                    label: Text('Copy')),
              ],
            ),
            SizedBox(height: 8),
            JsonViewerWidget(_draftStudy.toJson()),
          ],
        ),
      ),
    );
  }
}
