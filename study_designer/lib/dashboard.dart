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

  @override
  void initState() {
    super.initState();
    _studiesFuture = ParseStudy().getAll();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
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
                      Text('Draft studies')
                    ]),
                    initiallyExpanded: true,
                    children: ListTile.divideTiles(
                        context: context, tiles: draftStudies.map((study) => StudyCard(study: study))).toList(),
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
        onPressed: () => Navigator.pushNamed(context, designerRoute),
        tooltip: 'Add',
        child: Icon(Icons.add),
      ),
    );
  }
}

class StudyCard extends StatelessWidget {
  final ParseStudy study;

  const StudyCard({Key key, this.study}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(study.title),
      subtitle: Text(study.description),
      onTap: !study.published ? () => Navigator.pushNamed(context, designerRoute) : null,
    );
  }
}
