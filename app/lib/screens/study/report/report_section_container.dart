import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:studyou_core/models/models.dart';

import 'report_section_widget.dart';
import 'sections/report_section_widgets.dart';

typedef SectionBuilder = ReportSectionWidget Function(ReportSection section, UserStudy instance);

class ReportSectionContainer extends StatelessWidget {
  static Map<Type, SectionBuilder> sectionTypes = {
    AverageSection: (section, instance) => AverageSectionWidget(instance, section as AverageSection),
    LinearRegressionSection: (section, instance) =>
        LinearRegressionSectionWidget(instance, section as LinearRegressionSection),
  };

  final ReportSection section;
  final UserStudy instance;
  final bool primary;
  final GestureTapCallback onTap;

  const ReportSectionContainer(this.section, {@required this.instance, this.onTap, this.primary = false});

  ReportSectionWidget buildContents(BuildContext context) => sectionTypes[section.runtimeType](section, instance);

  List<Widget> buildPrimaryHeader(BuildContext context, ThemeData theme) => [
        Text(
          AppLocalizations.of(context).report_primary_result.toUpperCase(),
          style: theme.textTheme.overline.copyWith(color: theme.accentColor),
        ),
        SizedBox(height: 4),
      ];

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
              if (primary) ...buildPrimaryHeader(context, theme),
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
