import 'package:flutter/material.dart';
import 'package:studyou_core/models/models.dart';

import '../../../routes.dart';
import '../../../util/localization.dart';
import 'disclaimer_section.dart';
import 'general_details_section.dart';
import 'performance/performance_details.dart';
import 'performance/performance_section.dart';
import 'report_section_container.dart';

class ReportDetailsScreen extends StatelessWidget {
  final ParseUserStudy reportStudy;

  static MaterialPageRoute routeFor({@required ParseUserStudy reportStudy}) => MaterialPageRoute(
      builder: (_) => ReportDetailsScreen(reportStudy), settings: RouteSettings(name: Routes.reportDetails));

  const ReportDetailsScreen(this.reportStudy, {Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          Nof1Localizations.of(context).translate('report_overview'),
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
        scrollDirection: Axis.vertical,
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
              reportStudy.reportSpecification.primary,
              instance: reportStudy,
              primary: true,
            ),
            ...reportStudy.reportSpecification.secondary
                .map((section) => ReportSectionContainer(section, instance: reportStudy))
          ],
        ),
      ),
    );
  }
}
