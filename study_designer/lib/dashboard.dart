import 'dart:convert';
import 'dart:html';

import 'package:csv/csv.dart';
import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:parse_server_sdk/parse_server_sdk.dart';
import 'package:provider/provider.dart';
import 'package:studyou_core/models/models.dart';
import 'package:studyou_core/queries/queries.dart';
import 'package:studyou_core/util/localization.dart';
import 'package:studyou_core/util/parse_future_builder.dart';

import 'designer.dart';
import 'routes.dart';
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
        child: Text(Nof1Localizations.of(context).translate(locale.languageCode)),
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
          Theme(data: ThemeData.dark(), child: DropdownButtonHideUnderline(child: _buildLanguageDropdown())),
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
                      Text(Nof1Localizations.of(context).translate('draft_studies'))
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
                      Text(Nof1Localizations.of(context).translate('published_studies'))
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

  //TODO: Make this work on other platforms as well
  void downloadFile(String contentString, String filename) {
    final content = base64Encode(utf8.encode(contentString));
    AnchorElement(href: 'data:application/octet-stream;charset=utf-8;base64,$content')
      ..setAttribute('download', filename)
      ..click();
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
                      SnackBar(content: Text('${study.title} ${Nof1Localizations.of(context).translate('deleted')}')));
                  if (reload != null) reload();
                }
              },
            )
          : IconButton(
              icon: Icon(MdiIcons.tableArrowDown, color: Colors.green),
              tooltip: Nof1Localizations.of(context).translate('export_csv'),
              onPressed: () async {
                final dl = ResultDownloader(study);
                await dl.loadDetails();
                final results = await dl.loadAllResults();
                for (final entry in results.entries) {
                  downloadFile(ListToCsvConverter().convert(entry.value), '${study.id}.${entry.key.filename}.csv');
                }
              },
            ),
      onTap: !study.published
          ? () async {
              final res = await StudyQueries.getStudyWithDetails(study);
              final ParseStudy fullStudy = res.results.first;
              Navigator.push(context, Designer.draftRoute(study: fullStudy.toBase())).then((_) => reload());
            }
          : null,
    );
  }
}

class DeleteAlertDialog extends StatelessWidget {
  final ParseStudy study;

  const DeleteAlertDialog({@required this.study, Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) => AlertDialog(
        title: Text(Nof1Localizations.of(context).translate('delete_draft_study')),
        actions: [
          FlatButton.icon(
            onPressed: () async {
              await study.studyDetails.delete();
              await study.delete();
              Navigator.pop(context, true);
            },
            icon: Icon(Icons.delete),
            color: Colors.red,
            label: Text(Nof1Localizations.of(context).translate('delete')),
          )
        ],
      );
}
