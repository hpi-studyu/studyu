import 'package:clipboard/clipboard.dart';
import 'package:flutter/material.dart';
import 'package:flutter_json_widget/flutter_json_widget.dart';
import 'package:parse_server_sdk_flutter/parse_server_sdk.dart';
import 'package:pretty_json/pretty_json.dart';
import 'package:provider/provider.dart';
import 'package:studyou_core/models/models.dart';
import 'package:studyou_core/queries/study.dart';
import 'package:studyou_core/util/localization.dart';
import 'package:studyou_core/util/parse_future_builder.dart';

import '../models/designer_state.dart';

class Save extends StatefulWidget {
  @override
  _SaveState createState() => _SaveState();
}

class _SaveState extends State<Save> {
  StudyBase _draftStudy;
  Future<ParseResponse> _futureParseStudy;
  String studyObjectId;
  bool _hasAcceptedTerms = false;
  bool _showDebugOutput = false;

  @override
  void initState() {
    super.initState();
    _draftStudy = context.read<DesignerState>().draftStudy;
    _futureParseStudy = StudyQueries.getStudyWithDetailsByStudyId(_draftStudy.id);
  }

  Future<void> _publishStudy(BuildContext context, String studyObjectId, String studyDetailsObjectId) async {
    _draftStudy.published = true;
    final isSaved = await showDialog<bool>(
        context: context, builder: (_) => PublishAlertDialog(study: ParseStudy.fromBase(_draftStudy)));
    if (isSaved) {
      await _saveStudy(studyObjectId, studyDetailsObjectId);
      Scaffold.of(context).showSnackBar(SnackBar(
          content: Text('${_draftStudy.title} ${Nof1Localizations.of(context).translate('was_saved_and_published')}')));
      Navigator.popUntil(context, (route) => route.settings.name == '/');
    }
  }

  Future<void> _saveDraft(String studyObjectId, String studyDetailsObjectId) async {
    await _saveStudy(studyObjectId, studyDetailsObjectId);
    Scaffold.of(context).showSnackBar(SnackBar(
        content: Text('${_draftStudy.title} ${Nof1Localizations.of(context).translate('was_saved_as_draft')}')));
  }

  Future<void> _saveStudy(String studyObjectId, String studyDetailsObjectId) async {
    final parseStudy = ParseStudy.fromBase(_draftStudy);
    if (studyObjectId != null) {
      parseStudy.objectId = studyObjectId;
      parseStudy.studyDetails.objectId = studyDetailsObjectId;
    }
    setState(() {
      _futureParseStudy = parseStudy.save();
    });
    ;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ParseFetchOneFutureBuilder<ParseStudy>(
        queryFunction: () => _futureParseStudy,
        builder: (context, study) {
          return Padding(
            padding: const EdgeInsets.all(32),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(Nof1Localizations.of(context).translate('terms_title'), style: theme.textTheme.headline6),
                  CheckboxListTile(
                      title: Text(Nof1Localizations.of(context).translate('terms_agree')),
                      value: _hasAcceptedTerms,
                      onChanged: (val) => setState(() => _hasAcceptedTerms = val)),
                  SizedBox(height: 16),
                  Text(Nof1Localizations.of(context).translate('save'), style: theme.textTheme.headline6),
                  if (!_hasAcceptedTerms) Text(Nof1Localizations.of(context).translate('terms_description')),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      OutlineButton.icon(
                          onPressed: _hasAcceptedTerms
                              ? () => _saveDraft(study?.objectId, study?.studyDetails?.objectId)
                              : null,
                          icon: Icon(Icons.save),
                          label: Text(Nof1Localizations.of(context).translate('save_draft'),
                              style: TextStyle(fontSize: 30))),
                      SizedBox(width: 16),
                      OutlineButton.icon(
                          onPressed: _hasAcceptedTerms
                              ? () => _publishStudy(context, study?.objectId, study?.studyDetails?.objectId)
                              : null,
                          icon: Icon(Icons.publish),
                          label: Text(Nof1Localizations.of(context).translate('publish_study'),
                              style: TextStyle(fontSize: 30))),
                    ],
                  ),
                  SizedBox(height: 80),
                  Text(Nof1Localizations.of(context).translate('debug_output'), style: theme.textTheme.headline6),
                  CheckboxListTile(
                      title: Text(Nof1Localizations.of(context).translate('show_debug_output')),
                      value: _showDebugOutput,
                      onChanged: (val) => setState(() => _showDebugOutput = val)),
                  if (_showDebugOutput)
                    Column(children: [
                      Row(
                        children: [
                          Text(Nof1Localizations.of(context).translate('study_model_in_json')),
                          SizedBox(width: 8),
                          OutlineButton.icon(
                              onPressed: () async {
                                await FlutterClipboard.copy(prettyJson(_draftStudy.toJson()));
                                Scaffold.of(context).showSnackBar(
                                    SnackBar(content: Text(Nof1Localizations.of(context).translate('copy_json'))));
                              },
                              icon: Icon(Icons.copy),
                              label: Text(Nof1Localizations.of(context).translate('copy'))),
                        ],
                      ),
                      SizedBox(height: 8),
                      JsonViewerWidget(_draftStudy.toJson()),
                    ])
                ],
              ),
            ),
          );
        });
  }
}

class PublishAlertDialog extends StatelessWidget {
  final ParseStudy study;

  const PublishAlertDialog({@required this.study}) : super();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return AlertDialog(
      title: Text(Nof1Localizations.of(context).translate('lock_and_publish')),
      content: RichText(
        text: TextSpan(style: TextStyle(color: Colors.black), children: [
          TextSpan(text: 'The study '),
          TextSpan(
              text: study.title,
              style: TextStyle(color: theme.primaryColor, fontWeight: FontWeight.bold, fontSize: 16)),
          TextSpan(text: Nof1Localizations.of(context).translate('really_want_to_publish')),
        ]),
      ),
      actions: [
        FlatButton.icon(
          onPressed: () async {
            Navigator.pop(context, true);
          },
          icon: Icon(Icons.publish),
          color: Colors.green,
          label: Text('${Nof1Localizations.of(context).translate('publish')} ${study.title}'),
        )
      ],
    );
  }
}
