import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:studyu_app/screens/study/report/sections/average_section_widget.dart';
import 'package:studyu_app/screens/study/report/sections/linear_regression_section_widget.dart';
import 'package:studyu_core/core.dart';

import 'report_section_widget.dart';

typedef SectionBuilder = ReportSectionWidget Function(ReportSection section, StudySubject subject);

class ReportSectionContainer extends StatelessWidget {
  static Map<Type, SectionBuilder> sectionTypes = {
    AverageSection: (section, instance) => AverageSectionWidget(instance, section as AverageSection),
    LinearRegressionSection: (section, instance) =>
        LinearRegressionSectionWidget(instance, section as LinearRegressionSection),
  };

  final ReportSection section;
  final StudySubject subject;
  final bool primary;
  final GestureTapCallback? onTap;

  const ReportSectionContainer(this.section, {super.key, required this.subject, this.onTap, this.primary = false});

  ReportSectionWidget buildContents(BuildContext context) => sectionTypes[section.runtimeType]!(section, subject);

  List<Widget> buildPrimaryHeader(BuildContext context, ThemeData theme) => [
        Text(
          AppLocalizations.of(context)!.report_primary_result.toUpperCase(),
          style: theme.textTheme.labelSmall!.copyWith(color: theme.colorScheme.secondary),
        ),
        const SizedBox(height: 4),
      ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (primary) ...buildPrimaryHeader(context, theme),
              Text(
                section.title ?? '',
                style: theme.textTheme.headlineSmall,
              ),
              const SizedBox(height: 4),
              Text(
                section.description ?? '',
                style: theme.textTheme.bodyMedium,
              ),
              const SizedBox(height: 8),
              buildContents(context),
            ],
          ),
        ),
      ),
    );
  }
}
