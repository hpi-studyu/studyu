import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:studyou_core/models/models.dart';

import '../../../routes.dart';
import '../../../util/localization.dart';
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
        actions: [
          IconButton(
            icon: Icon(MdiIcons.download),
            // TODO add pdf download
            onPressed: () => null,
          ),
        ],
      ),
      body: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            GeneralDetailsSection(reportStudy),
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
