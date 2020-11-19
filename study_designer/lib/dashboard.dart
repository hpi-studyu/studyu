import 'dart:convert';
import 'dart:io';

import 'package:csv/csv.dart';
import 'package:ext_storage/ext_storage.dart';
import 'package:flutter/foundation.dart' show kIsWeb, kReleaseMode;
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:parse_server_sdk_flutter/parse_server_sdk.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:studyou_core/models/models.dart';
import 'package:studyou_core/queries/queries.dart';
import 'package:studyou_core/util/localization.dart';
import 'package:studyou_core/util/parse_future_builder.dart';
import 'package:universal_html/prefer_universal/html.dart' as html;

import 'designer.dart';
import 'routes.dart';
import 'util/localization.dart';
import 'util/result_downloader.dart';

class Dashboard extends StatefulWidget {
  @override
  _DashboardState createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  Future<ParseResponse> _studiesFuture;
  Locale _selectedLocal;

  @override
  void initState() {
    super.initState();
    _selectedLocal = context.read<AppLanguage>().appLocal;
    reloadStudies();
  }

  void reloadStudies() {
    setState(() {
      _studiesFuture = ParseStudy().getAll();
    });
  }

  Widget _buildLanguageDropdown() {
    final dropDownItems = <DropdownMenuItem<Locale>>[];

    for (final locale in AppLanguage.supportedLocales) {
      dropDownItems.add(DropdownMenuItem(
        value: locale,
        child: Text(localeName(context, locale.languageCode)),
      ));
    }

    dropDownItems.add(DropdownMenuItem(
      value: null,
      child: Text('System'),
    ));

    return DropdownButton(
      value: _selectedLocal,
      items: dropDownItems,
      onChanged: (value) {
        setState(() {
          _selectedLocal = value;
        });
        context.read<AppLanguage>().changeLanguage(value);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text('StudyU Designer'),
        actions: [
          kReleaseMode
              ? Container()
              : Builder(builder: (context) {
                  return Theme(
                    data: ThemeData.dark(),
                    child: FlatButton.icon(
                      label: Text('Upload'),
                      icon: Icon(MdiIcons.upload),
                      onPressed: () async {
                        final controller = TextEditingController();
                        final wasUploaded = await showDialog<bool>(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: Text('Paster Study JSON here'),
                            actions: [
                              FlatButton.icon(
                                label: Text('Cancel'),
                                icon: Icon(MdiIcons.close),
                                onPressed: () {
                                  Navigator.pop(context, false);
                                },
                              ),
                              FlatButton.icon(
                                label: Text('Upload'),
                                icon: Icon(MdiIcons.upload),
                                onPressed: () {
                                  try {
                                    final Map<String, dynamic> studyJson = json.decode(controller.text);
                                    final study = StudyBase.fromJson(studyJson);
                                    ParseStudy.fromBase(study).save();
                                    Navigator.pop(context, true);
                                  } on FormatException {
                                    controller.text = 'This is not valid JSON! Please paste valid JSON.';
                                  }
                                },
                              ),
                            ],
                            content: TextField(
                              controller: controller,
                              minLines: 100,
                              maxLines: 10000,
                            ),
                          ),
                        );
                        if (wasUploaded) {
                          print('uploaded');
                          Scaffold.of(context)
                              .showSnackBar(SnackBar(content: Text('Successfully imported study JSON 🎉')));
                        }
                      },
                    ),
                  );
                }),
          Theme(
            data: ThemeData.dark(),
            child: DropdownButtonHideUnderline(
              child: _buildLanguageDropdown(),
            ),
          ),
        ],
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: ParseListFutureBuilder<ParseStudy>(
            queryFunction: () => _studiesFuture,
            builder: (context, studies) {
              final draftStudies = studies.where((s) => !s.published).toList();
              final publishedStudies = studies.where((s) => s.published).toList();
              return ListView(
                children: [
                  ExpansionTile(
                    title: Row(children: [
                      Icon(Icons.edit, color: theme.accentColor),
                      SizedBox(width: 8),
                      Text(AppLocalizations.of(context).draft_studies)
                    ]),
                    initiallyExpanded: true,
                    children: ListTile.divideTiles(
                        context: context,
                        tiles: draftStudies.map((study) => StudyCard(
                              study: study,
                              reload: reloadStudies,
                            ))).toList(),
                  ),
                  ExpansionTile(
                    title: Row(children: [
                      Icon(Icons.lock, color: theme.accentColor),
                      SizedBox(width: 8),
                      Text(AppLocalizations.of(context).published_studies)
                    ]),
                    initiallyExpanded: true,
                    children: ListTile.divideTiles(
                        context: context,
                        tiles: publishedStudies.map((study) => StudyCard(
                              study: study,
                              reload: reloadStudies,
                            ))).toList(),
                  )
                ],
              );
            },
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.pushNamed(context, designerRoute).then((_) => reloadStudies()),
        tooltip: 'Add',
        child: Icon(Icons.add),
      ),
    );
  }
}

class StudyCard extends StatelessWidget {
  final ParseStudy study;
  final Function reload;

  const StudyCard({@required this.study, @required this.reload, Key key}) : super(key: key);

  Future<void> downloadFile(String contentString, String filename) async {
    if (kIsWeb) {
      final bytes = utf8.encode(contentString);
      final blob = html.Blob([bytes]);
      final url = html.Url.createObjectUrlFromBlob(blob);
      // ignore: avoid_as
      final anchor = html.document.createElement('a') as html.AnchorElement
        ..href = url
        ..style.display = 'none'
        ..download = filename;
      html.document.body.children.add(anchor);

      anchor.click();

      html.document.body.children.remove(anchor);
      html.Url.revokeObjectUrl(url);
    } else {
      final dirPath = Platform.isIOS
          ? (await getApplicationDocumentsDirectory()).path
          : await ExtStorage.getExternalStoragePublicDirectory(ExtStorage.DIRECTORY_DOCUMENTS);

      File('$dirPath/$filename').writeAsString(contentString);
    }
  }

  @override
  Widget build(BuildContext context) {
    final icon =
        study.iconName != null && study.iconName.isNotEmpty ? MdiIcons.fromString(study.iconName) : MdiIcons.cropSquare;

    return ListTile(
        title: Text(study.title),
        subtitle: Text(study.description),
        leading: Icon(icon),
        trailing: !study.published
            ? IconButton(
                icon: Icon(Icons.delete, color: Colors.red),
                onPressed: () async {
                  final isDeleted =
                      await showDialog<bool>(context: context, builder: (_) => DeleteAlertDialog(study: study));
                  if (isDeleted) {
                    Scaffold.of(context).showSnackBar(
                        SnackBar(content: Text('${study.title} ${AppLocalizations.of(context).deleted}')));
                    if (reload != null) reload();
                  }
                },
              )
            : IconButton(
                icon: Icon(MdiIcons.tableArrowDown, color: Colors.green),
                tooltip: AppLocalizations.of(context).export_csv,
                onPressed: () async {
                  final dl = ResultDownloader(study);
                  await dl.loadDetails();
                  final results = await dl.loadAllResults();
                  for (final entry in results.entries) {
                    downloadFile(ListToCsvConverter().convert(entry.value), '${study.id}.${entry.key.filename}.csv');
                  }
                },
              ),
        onTap: () async {
          final res = await StudyQueries.getStudyWithDetails(study);
          final ParseStudy fullStudy = res.results.first;
          Navigator.push(context, Designer.draftRoute(study: fullStudy.toBase())).then((_) => reload());
        });
  }
}

class DeleteAlertDialog extends StatelessWidget {
  final ParseStudy study;

  const DeleteAlertDialog({@required this.study, Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) => AlertDialog(
        title: Text(AppLocalizations.of(context).delete_draft_study),
        actions: [
          FlatButton.icon(
            onPressed: () async {
              await study.studyDetails.delete();
              await study.delete();
              Navigator.pop(context, true);
            },
            icon: Icon(Icons.delete),
            color: Colors.red,
            label: Text(AppLocalizations.of(context).delete),
          )
        ],
      );
}
