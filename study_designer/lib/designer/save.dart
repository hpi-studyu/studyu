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

  Future<void> _publishStudy(BuildContext context) async {
    _draftStudy.published = true;
    final isSaved = await showDialog<bool>(
        context: context, builder: (_) => PublishAlertDialog(study: ParseStudy.fromBase(_draftStudy)));
    if (isSaved) {
      Scaffold.of(context).showSnackBar(SnackBar(content: Text('Study ${_draftStudy.title} was saved and published.')));
      Navigator.popUntil(context, (route) => route.settings.name == '/');
    }
  }

  Future<void> _saveDraft() async {
    await ParseStudy.fromBase(_draftStudy).save();
    Scaffold.of(context).showSnackBar(SnackBar(content: Text('Study ${_draftStudy.title} was saved as draft.')));
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
                    onPressed: () => _publishStudy(context),
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

class PublishAlertDialog extends StatelessWidget {
  final ParseStudy study;

  const PublishAlertDialog({@required this.study}) : super();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return AlertDialog(
      title: Text('Lock and publish study?'),
      content: RichText(
        text: TextSpan(style: TextStyle(color: Colors.black), children: [
          TextSpan(text: 'The study '),
          TextSpan(
              text: study.title,
              style: TextStyle(color: theme.primaryColor, fontWeight: FontWeight.bold, fontSize: 16)),
          TextSpan(text: ' will be published. You will not be able to make changes afterwards!'),
        ]),
      ),
      actions: [
        FlatButton.icon(
          onPressed: () async {
            //await study.save();
            Navigator.pop(context, true);
          },
          icon: Icon(Icons.publish),
          color: Colors.green,
          label: Text('Publish ${study.title}'),
        )
      ],
    );
  }
}
