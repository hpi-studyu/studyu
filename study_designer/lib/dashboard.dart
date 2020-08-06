import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:parse_server_sdk/parse_server_sdk.dart';
import 'package:study_designer/routes.dart';
import 'package:studyou_core/models/models.dart';
import 'package:studyou_core/util/parse_future_builder.dart';

class Dashboard extends StatefulWidget {
  @override
  _DashboardState createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  Future<ParseResponse> _studiesFuture;

  @override
  void initState() {
    super.initState();
    _studiesFuture = Study().getAll();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('StudYou Designer'),
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
          child: ParseListFutureBuilder<Study>(
            queryFunction: () => _studiesFuture,
            builder: (context, studies) {
              return ListView.builder(
                itemCount: studies.length,
                itemBuilder: (context, index) => StudyCard(study: studies[index]),
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
  final Study study;

  const StudyCard({Key key, this.study}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Column(
        children: [
          ListTile(
            title: Text(study.title),
            subtitle: Text(study.description),
          )
        ],
      ),
    );
  }
}
