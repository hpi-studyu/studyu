import 'package:StudYou/screens/study/report/sections/report_section_widgets.dart';
import 'package:flutter/material.dart';
import 'package:studyou_core/models/report/report_models.dart';
import 'package:studyou_core/models/study/parse_user_study.dart';

import 'report_section_widget.dart';

typedef SectionBuilder = ReportSectionWidget Function(ReportSection section, ParseUserStudy instance);

class ReportSectionContainer extends StatelessWidget {
  static Map<Type, SectionBuilder> sectionTypes = {
    AverageSection: (section, instance) => AverageSectionWidget(instance, section, primary: true),
  };

  final ReportSection section;
  final ParseUserStudy instance;
  final Function onTap;

  const ReportSectionContainer(this.section, {@required this.instance, this.onTap});

  ReportSectionWidget buildContents(BuildContext context) => sectionTypes[section.runtimeType](section, instance);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                section.title,
                style: theme.textTheme.headline5,
              ),
              SizedBox(height: 4),
              Text(
                section.description,
                style: theme.textTheme.bodyText2,
              ),
              SizedBox(height: 8),
              buildContents(context),
            ],
          ),
        ),
      ),
    );
  }
}
