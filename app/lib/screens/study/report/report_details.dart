import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:studyou_core/core.dart';

import '../../../routes.dart';
import 'disclaimer_section.dart';
import 'general_details_section.dart';
import 'performance/performance_details.dart';
import 'performance/performance_section.dart';
import 'report_section_container.dart';

class ReportDetailsScreen extends StatelessWidget {
  final StudySubject reportStudy;

  static MaterialPageRoute routeFor({@required StudySubject reportStudy}) => MaterialPageRoute(
      builder: (_) => ReportDetailsScreen(reportStudy), settings: RouteSettings(name: Routes.reportDetails));

  const ReportDetailsScreen(this.reportStudy, {Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          AppLocalizations.of(context).report_overview,
        ),
        // TODO add pdf download
        // actions: [
        //   IconButton(
        //     icon: Icon(MdiIcons.download),
        //     onPressed: () => null,
        //   ),
        // ],
      ),
      body: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            GeneralDetailsSection(reportStudy),
            DisclaimerSection(reportStudy),
            PerformanceSection(
              reportStudy,
              onTap: () => Navigator.push(context, PerformanceDetailsScreen.routeFor(reportStudy: reportStudy)),
            ),
            ReportSectionContainer(
              reportStudy.study.reportSpecification.primary,
              instance: reportStudy,
              primary: true,
            ),
            ...reportStudy.study.reportSpecification.secondary
                .map((section) => ReportSectionContainer(section, instance: reportStudy))
          ],
        ),
      ),
    );
  }
}
