import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:provider/provider.dart';
import 'package:studyou_core/models/models.dart';
import 'package:studyou_core/queries/queries.dart';
import 'package:studyou_core/util/localization.dart';
import 'package:studyou_core/util/parse_future_builder.dart';

import '../../../models/app_state.dart';
import 'report_details.dart';

class ReportHistoryScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          Nof1Localizations.of(context).translate('report_history'),
        ),
      ),
      body: ParseListFutureBuilder<ParseUserStudy>(
        queryFunction: StudyQueries.getStudyHistory,
        builder: (context, pastStudies) {
          return ListView.builder(
            itemCount: pastStudies.length,
            itemBuilder: (context, index) {
              return ReportHistoryItem(pastStudies[index]);
            },
          );
        },
      ),
    );
  }
}

class ReportHistoryItem extends StatelessWidget {
  final ParseUserStudy study;

  const ReportHistoryItem(this.study);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final model = context.watch<AppState>();
    final isActiveStudy = model.activeStudy.studyId == study.studyId;
    return Card(
      color: isActiveStudy ? Colors.green[600] : theme.cardColor,
      child: InkWell(
        onTap: () {
          Navigator.push(context, ReportDetailsScreen.routeFor(reportStudy: study));
        },
        child: Padding(
          padding: EdgeInsets.all(20),
          child: Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Icon(MdiIcons.fromString(study.iconName) ?? MdiIcons.accountHeart,
                    color: isActiveStudy ? Colors.white : Colors.black),
                Text(study.title,
                    style: theme.textTheme.headline5.copyWith(color: isActiveStudy ? Colors.white : Colors.black)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
