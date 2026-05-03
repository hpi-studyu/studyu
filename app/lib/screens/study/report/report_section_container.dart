import 'package:flutter/material.dart';
import 'package:studyu_app/l10n/app_localizations.dart';
import 'package:studyu_app/screens/study/report/report_section_widget.dart';
import 'package:studyu_app/screens/study/report/sections/average_section_widget.dart';
import 'package:studyu_app/screens/study/report/sections/descriptive_stats_section_widget.dart';
import 'package:studyu_app/screens/study/report/sections/gauge_comparison_section_widget.dart';
import 'package:studyu_app/screens/study/report/sections/linear_regression_section_widget.dart';
import 'package:studyu_app/screens/study/report/sections/textual_summary_section_widget.dart';
import 'package:studyu_app/spacing.dart';
import 'package:studyu_core/core.dart';

typedef SectionBuilder =
    ReportSectionWidget Function(ReportSection section, StudySubject subject);

class ReportSectionContainer extends StatelessWidget {
  final ReportSection section;
  final StudySubject subject;
  final bool primary;
  final GestureTapCallback? onTap;

  const ReportSectionContainer(
    this.section, {
    super.key,
    required this.subject,
    this.onTap,
    this.primary = false,
  });

  ReportSectionWidget buildContents(BuildContext context) => switch (section) {
    final AverageSection averageSection => AverageSectionWidget(
      subject,
      averageSection,
    ),
    final LinearRegressionSection linearRegressionSection =>
      LinearRegressionSectionWidget(subject, linearRegressionSection),
    final TextualSummarySection textualSummarySection =>
      TextualSummarySectionWidget(subject, textualSummarySection),
    final GaugeComparisonSection gaugeComparisonSection =>
      GaugeComparisonSectionWidget(subject, gaugeComparisonSection),
    final DescriptiveStatsSection descriptiveStatsSection =>
      DescriptiveStatsSectionWidget(subject, descriptiveStatsSection),
    _ => throw ArgumentError('Section type ${section.type} not supported.'),
  };

  List<Widget> buildPrimaryHeader(BuildContext context, ThemeData theme) => [
    Text(
      AppLocalizations.of(context)!.report_primary_result.toUpperCase(),
      style: theme.textTheme.labelSmall!.copyWith(
        color: theme.colorScheme.secondary,
      ),
    ),
    const SizedBox(height: StudyUSpacing.space1),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(StudyUSpacing.space4),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (primary) ...buildPrimaryHeader(context, theme),
              Text(section.title ?? '', style: theme.textTheme.headlineSmall),
              const SizedBox(height: StudyUSpacing.space1),
              Text(
                section.description ?? '',
                style: theme.textTheme.bodyMedium,
              ),
              const SizedBox(height: StudyUSpacing.space2),
              buildContents(context),
            ],
          ),
        ),
      ),
    );
  }
}
