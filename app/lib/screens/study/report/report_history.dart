import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:studyou_core/models/models.dart';
import 'package:studyou_core/queries/queries.dart';

import '../../../models/app_state.dart';
import '../../../routes.dart';
import '../../../util/localization.dart';

class ReportHistoryScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          Nof1Localizations.of(context).translate('report_history'),
        ),
      ),
      body: FutureBuilder(
        future: StudyQueries.getStudyHistory(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return Center(child: CircularProgressIndicator());
          if (snapshot.data is! List<StudyInstance>) return Center(child: Text('ERROR'));
          return ListView.builder(
            itemCount: snapshot.data.length,
            itemBuilder: (context, index) {
              return ReportHistoryItem(snapshot.data[index]);
            },
          );
        },
      ),
    );
  }
}

class ReportHistoryItem extends StatelessWidget {
  final StudyInstance instance;

  const ReportHistoryItem(this.instance);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final model = context.watch<AppModel>();
    return Card(
      color: model.activeStudy.studyId == instance.studyId ? Colors.green[600] : theme.cardColor,
      child: InkWell(
        onTap: () {
          model.reportStudy = instance;
          Navigator.pushNamed(context, Routes.reportDetails);
        },
        child: Padding(
          padding: EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(instance.title, style: theme.textTheme.headline5),
            ],
          ),
        ),
      ),
    );
  }
}
