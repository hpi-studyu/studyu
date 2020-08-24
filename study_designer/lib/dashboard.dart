import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:parse_server_sdk/parse_server_sdk.dart';
import 'package:studyou_core/models/models.dart';
import 'package:studyou_core/util/parse_future_builder.dart';

import 'routes.dart';

class Dashboard extends StatefulWidget {
  @override
  _DashboardState createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  Future<ParseResponse> _studiesFuture;
  Future<ParseResponse> Function() _studiesQueryFuture;

  @override
  void initState() {
    super.initState();
    _studiesFuture = ParseStudy().getAll();
    _studiesQueryFuture = () => _studiesFuture;
  }

  void reloadStudies() {
    setState(() {
      _studiesFuture = ParseStudy().getAll();
      _studiesQueryFuture = () => _studiesFuture;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    print('+++++++++++++++++++++CALLING BUILD ---------------------------------------------');
    return Scaffold(
      appBar: AppBar(
        title: Text('StudyU Designer'),
        actions: [
          IconButton(
            onPressed: () {},
            icon: Icon(MdiIcons.logout),
          )
        ],
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: ParseListFutureBuilder<ParseStudy>(
            queryFunction: _studiesQueryFuture,
            builder: (context, studies) {
              print('BUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUILINDG');
              final draftStudies = studies.where((s) => !s.published).toList();
              print(draftStudies.map((s) => s.title).toString());
              final publishedStudies = studies.where((s) => s.published).toList();
              return ListView(
                children: [
                  ExpansionTile(
                    title: Row(children: [
                      Icon(Icons.edit, color: theme.accentColor),
                      SizedBox(width: 8),
                      Text('Draft studies')
                    ]),
                    initiallyExpanded: true,
                    children: ListTile.divideTiles(
                        context: context,
                        tiles: draftStudies.map((study) => StudyCard(study: study, onDelete: reloadStudies))).toList(),
                  ),
                  ExpansionTile(
                    title: Row(children: [
                      Icon(Icons.lock, color: theme.accentColor),
                      SizedBox(width: 8),
                      Text('Published studies')
                    ]),
                    initiallyExpanded: true,
                    children: ListTile.divideTiles(
                        context: context, tiles: publishedStudies.map((study) => StudyCard(study: study))).toList(),
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
  final Function onDelete;

  const StudyCard({@required this.study, this.onDelete, Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(study.title),
      subtitle: Text(study.description),
      trailing: !study.published
          ? IconButton(
              icon: Icon(Icons.delete, color: Colors.red),
              onPressed: () async {
                final isDeleted =
                    await showDialog<bool>(context: context, builder: (_) => DeleteAlertDialog(study: study));
                if (isDeleted) {
                  Scaffold.of(context).showSnackBar(SnackBar(content: Text('Draft study ${study.title} deleted.')));
                  if (onDelete != null) onDelete();
                }
                ;
              },
            )
          : null,
      onTap: !study.published ? () => Navigator.pushNamed(context, designerRoute) : null,
    );
  }
}

class DeleteAlertDialog extends StatelessWidget {
  final ParseStudy study;

  const DeleteAlertDialog({@required this.study, Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) => AlertDialog(
        title: Text('Delete draft study ${study.title}?'),
        actions: [
          FlatButton.icon(
            onPressed: () async {
              await study.studyDetails.delete();
              await study.delete();
              Navigator.pop(context, true);
            },
            icon: Icon(Icons.delete),
            color: Colors.red,
            label: Text('Delete ${study.title}'),
          )
        ],
      );
}
