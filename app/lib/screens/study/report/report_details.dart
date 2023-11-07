import 'package:flutter/foundation.dart' show kDebugMode;
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:studyu_core/core.dart';

import '../../../routes.dart';
import 'disclaimer_section.dart';
import 'general_details_section.dart';
import 'performance/performance_details.dart';
import 'performance/performance_section.dart';
import 'report_section_container.dart';

class ReportDetailsScreen extends StatelessWidget {
  final StudySubject subject;

  static MaterialPageRoute routeFor({required StudySubject subject}) => MaterialPageRoute(
        builder: (_) => ReportDetailsScreen(subject),
        settings: const RouteSettings(name: Routes.reportDetails),
      );

  const ReportDetailsScreen(this.subject, {super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          AppLocalizations.of(context)!.report_overview,
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
            GeneralDetailsSection(subject),
            DisclaimerSection(subject),
            PerformanceSection(
              subject,
              onTap: () => Navigator.push(context, PerformanceDetailsScreen.routeFor(subject: subject)),
            ),
            if (subject.study.reportSpecification.primary != null && (subject.completedStudy || kDebugMode))
              ReportSectionContainer(
                subject.study.reportSpecification.primary!,
                subject: subject,
                primary: true,
              ),
            if (subject.study.reportSpecification.secondary.isNotEmpty && (subject.completedStudy || kDebugMode))
              ...subject.study.reportSpecification.secondary
                  .map((section) => ReportSectionContainer(section, subject: subject))
          ],
        ),
      ),
    );
  }
}
