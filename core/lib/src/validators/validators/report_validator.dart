import 'package:studyu_core/src/models/data/data_reference.dart';
import 'package:studyu_core/src/models/observations/tasks/questionnaire_task.dart';
import 'package:studyu_core/src/models/report/report_section.dart';
import 'package:studyu_core/src/models/report/sections/average_section.dart';
import 'package:studyu_core/src/models/report/sections/descriptive_stats_section.dart';
import 'package:studyu_core/src/models/report/sections/gauge_comparison_section.dart';
import 'package:studyu_core/src/models/report/sections/linear_regression_section.dart';
import 'package:studyu_core/src/models/report/sections/textual_summary_section.dart';
import 'package:studyu_core/src/models/tables/study.dart';
import 'package:studyu_core/src/validators/validation_result.dart';

DataReference<dynamic>? _extractResultProperty(ReportSection section) {
  if (section is AverageSection) return section.resultProperty;
  if (section is LinearRegressionSection) return section.resultProperty;
  if (section is DescriptiveStatsSection) return section.resultProperty;
  if (section is GaugeComparisonSection) return section.resultProperty;
  if (section is TextualSummarySection) return section.resultProperty;
  return null;
}

ValidationResult _validateSection(
  ReportSection section,
  String path,
  Study study,
) {
  final errors = <ValidationError>[];
  final ref = _extractResultProperty(section);
  if (ref == null) return ValidationResult.empty();

  final observation = study.observations
      .cast<dynamic>()
      .firstWhere((o) => o.id == ref.task, orElse: () => null);

  if (observation == null) {
    errors.add(ValidationError(
      code: 'report.task_reference_missing',
      path: '$path.resultProperty.task',
      message: 'Report section references observation "${ref.task}" which does not exist',
      fixHint: 'Set resultProperty.task to an existing observation id',
    ));
    return ValidationResult(errors: errors, warnings: []);
  }

  if (observation is QuestionnaireTask) {
    final questionExists =
        observation.questions.questions.any((q) => q.id == ref.property);
    if (!questionExists) {
      errors.add(ValidationError(
        code: 'report.property_reference_missing',
        path: '$path.resultProperty.property',
        message:
            'Report section references question "${ref.property}" which does not exist in observation "${ref.task}"',
        fixHint:
            'Set resultProperty.property to a question id within that observation',
      ));
    }
  }

  return ValidationResult(errors: errors, warnings: []);
}

ValidationResult validateReport(Study study, ValidationLevel level) {
  final sections = [
    if (study.reportSpecification.primary != null)
      study.reportSpecification.primary!,
    ...study.reportSpecification.secondary,
  ];

  final results = <ValidationResult>[];
  int secondaryIdx = 0;
  for (var i = 0; i < sections.length; i++) {
    final section = sections[i];
    final isPrimary = study.reportSpecification.primary == section;
    final path = isPrimary
        ? r'$.report_specification.primary'
        : r'$.report_specification.secondary' + '[${secondaryIdx++}]';
    results.add(_validateSection(section, path, study));
  }

  return ValidationResult.merge(results);
}
