import 'package:clipboard/clipboard.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_json_widget/flutter_json_widget.dart';
import 'package:pretty_json/pretty_json.dart';
import 'package:provider/provider.dart';
import 'package:studyou_core/models/models.dart';
import 'package:studyou_core/queries/study.dart';
import 'package:studyou_core/util/parse_future_builder.dart';
import 'package:studyu_designer/designer/help_wrapper.dart';
import 'package:studyu_designer/models/app_state.dart';

class Save extends StatefulWidget {
  @override
  _SaveState createState() => _SaveState();
}

class _SaveState extends State<Save> {
  StudyBase _draftStudy;
  String studyObjectId;

  @override
  void initState() {
    super.initState();
    _draftStudy = context.read<AppState>().draftStudy;
  }

  Future<void> _publishStudy(BuildContext context, String studyObjectId, String studyDetailsObjectId) async {
    _draftStudy.published = true;
    final publishingAccepted = await showDialog<bool>(
        context: context, builder: (_) => PublishAlertDialog(study: ParseStudy.fromBase(_draftStudy)));
    if (publishingAccepted) {
      final wasSaved = await _saveStudy(studyObjectId, studyDetailsObjectId);
      if (wasSaved) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('${_draftStudy.title} ${AppLocalizations.of(context).was_saved_and_published}')));
        Navigator.popUntil(context, (route) => route.settings.name == '/');
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('${_draftStudy.title} ${AppLocalizations.of(context).failed_saving}')));
      }
    }
  }

  Future<void> _saveDraft(String studyObjectId, String studyDetailsObjectId) async {
    final wasSaved = await _saveStudy(studyObjectId, studyDetailsObjectId);
    if (wasSaved) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${_draftStudy.title} ${AppLocalizations.of(context).was_saved_as_draft}')));
    } else {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('${_draftStudy.title} ${AppLocalizations.of(context).failed_saving}')));
    }
  }

  Future<bool> _saveStudy(String studyObjectId, String studyDetailsObjectId) async {
    final parseStudy = ParseStudy.fromBase(_draftStudy);
    if (studyObjectId != null) {
      parseStudy.objectId = studyObjectId;
      parseStudy.studyDetails.objectId = studyDetailsObjectId;
    }
    final response = await parseStudy.save();
    return response.success;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return DesignerHelpWrapper(
      helpTitle: AppLocalizations.of(context).save_help_title,
      helpText: AppLocalizations.of(context).save_help_body,
      studyPublished: _draftStudy.published,
      child: ParseFetchOneFutureBuilder<ParseStudy>(
          // TODO: only fetch objectId of study and details
          queryFunction: () => StudyQueries.getStudyWithDetailsByStudyId(_draftStudy.id),
          builder: (context, study) {
            return Padding(
              padding: const EdgeInsets.all(32),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(AppLocalizations.of(context).save, style: theme.textTheme.headline6),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        OutlineButton.icon(
                            onPressed: () => _saveDraft(study?.objectId, study?.studyDetails?.objectId),
                            icon: Icon(Icons.save),
                            label: Text(AppLocalizations.of(context).save_draft, style: TextStyle(fontSize: 30))),
                        SizedBox(width: 16),
                        OutlineButton.icon(
                            onPressed: () => _publishStudy(context, study?.objectId, study?.studyDetails?.objectId),
                            icon: Icon(Icons.publish),
                            label: Text(AppLocalizations.of(context).publish_study, style: TextStyle(fontSize: 30))),
                      ],
                    ),
                    SizedBox(height: 80),
                    JSONExportSection(study: _draftStudy),
                  ],
                ),
              ),
            );
          }),
    );
  }
}

class JSONExportSection extends StatefulWidget {
  final StudyBase study;

  const JSONExportSection({@required this.study, Key key}) : super(key: key);

  @override
  _JSONExportSectionState createState() => _JSONExportSectionState();
}

class _JSONExportSectionState extends State<JSONExportSection> {
  bool _showDebugOutput = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      children: [
        Text(AppLocalizations.of(context).debug_output, style: theme.textTheme.headline6),
        CheckboxListTile(
            title: Text(AppLocalizations.of(context).show_debug_output),
            value: _showDebugOutput,
            onChanged: (val) => setState(() => _showDebugOutput = val)),
        if (_showDebugOutput)
          Column(children: [
            Row(
              children: [
                Text(AppLocalizations.of(context).study_model_in_json),
                SizedBox(width: 8),
                OutlineButton.icon(
                    onPressed: () async {
                      await FlutterClipboard.copy(prettyJson(widget.study.toJson()));
                      ScaffoldMessenger.of(context)
                          .showSnackBar(SnackBar(content: Text(AppLocalizations.of(context).copied_json)));
                    },
                    icon: Icon(Icons.copy),
                    label: Text(AppLocalizations.of(context).copy)),
              ],
            ),
            SizedBox(height: 8),
            JsonViewerWidget(widget.study.toJson()),
          ])
      ],
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
      title: Text(AppLocalizations.of(context).lock_and_publish),
      content: RichText(
        text: TextSpan(style: TextStyle(color: Colors.black), children: [
          TextSpan(text: 'The study '),
          TextSpan(
              text: study.title,
              style: TextStyle(color: theme.primaryColor, fontWeight: FontWeight.bold, fontSize: 16)),
          TextSpan(text: AppLocalizations.of(context).really_want_to_publish),
        ]),
      ),
      actions: [
        FlatButton.icon(
          onPressed: () async {
            Navigator.pop(context, true);
          },
          icon: Icon(Icons.publish),
          color: Colors.green,
          label: Text('${AppLocalizations.of(context).publish} ${study.title}'),
        )
      ],
    );
  }
}
