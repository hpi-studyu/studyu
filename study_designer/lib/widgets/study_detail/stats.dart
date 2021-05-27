import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:studyou_core/core.dart';

import '../icon_labels.dart';

class Stats extends StatelessWidget {
  final Study study;
  final Function() reload;

  const Stats({@required this.study, this.reload, Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ExpansionTile(
        childrenPadding: EdgeInsets.all(16),
        // expandedAlignment: Alignment.centerLeft,
        expandedCrossAxisAlignment: CrossAxisAlignment.start,
        leading: Icon(MdiIcons.chartLine),
        title: IntrinsicHeight(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Statistics', style: TextStyle(fontSize: 20)),
              Spacer(),
              IconLabel(label: study.participantCount.toString(), iconData: MdiIcons.accountGroup, color: Colors.red),
              VerticalDivider(),
              IconLabel(label: study.completedCount.toString(), iconData: MdiIcons.flagCheckered, color: Colors.black),
              VerticalDivider(),
              IconLabel(label: study.activeSubjectCount.toString(), iconData: MdiIcons.run, color: Colors.green),
            ],
          ),
        ),
        children: [
          IconLabel(
              label: '${study.participantCount.toString()} total participants',
              iconData: MdiIcons.accountGroup,
              color: Colors.red),
          SizedBox(height: 16),
          IconLabel(
              label: '${study.completedCount.toString()} subjects have completed the study',
              iconData: MdiIcons.flagCheckered,
              color: Colors.black),
          SizedBox(height: 16),
          IconLabel(
              label: '${study.activeSubjectCount.toString()} subjects have completed a task in the last 3 days',
              iconData: MdiIcons.run,
              color: Colors.green),
        ],
      ),
    );
  }
}
