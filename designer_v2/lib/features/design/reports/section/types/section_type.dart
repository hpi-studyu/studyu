import 'package:flutter/material.dart';
import 'package:studyu_core/core.dart';
import 'package:studyu_designer_v2/localization/app_translation.dart';

enum ReportSectionType {
  average,
  linearRegression;

  static ReportSectionType of(ReportSection reportSection) {
    final typeMapping = {
      AverageSection.sectionType: ReportSectionType.average,
      LinearRegressionSection.sectionType: ReportSectionType.linearRegression,
    };
    if (!typeMapping.containsKey(reportSection.type)) {
      throw UnimplementedError("Missing ReportSectionType for reportSection of type: ${reportSection.type}");
    }
    return typeMapping[reportSection.type]!;
  }

  String get string {
    switch (this) {
      case ReportSectionType.average:
        return tr.reportSection_type_average;
      case ReportSectionType.linearRegression:
        return tr.reportSection_type_linearRegression;
      default:
        return "[Invalid ReportSectionType]";
    }
  }

  IconData? get icon {
    switch (this) {
      case ReportSectionType.average:
        return Icons.functions_rounded;
      case ReportSectionType.linearRegression:
        return Icons.insights_rounded;
      default:
        return null;
    }
  }

  String toJson() => name;
  static ReportSectionType fromJson(String json) => values.byName(json);
}

extension TemporalAggregationFormatted on TemporalAggregation {
  String get string {
    switch (this) {
      case TemporalAggregation.day:
        return tr.reportSection_type_temporalAggregation_day;
      case TemporalAggregation.phase:
        return tr.reportSection_type_temporalAggregation_phase;
      case TemporalAggregation.intervention:
        return tr.reportSection_type_temporalAggregation_intervention;
      default:
        return "[Invalid TemporalAggregation]";
    }
  }

  IconData? get icon {
    switch (this) {
      case TemporalAggregation.day:
        return Icons.calendar_month_rounded;
      case TemporalAggregation.phase:
        return Icons.fast_forward_rounded;
      case TemporalAggregation.intervention:
        return Icons.task_alt_rounded;
      default:
        return null;
    }
  }
}

extension ImprovementDirectionFormatted on ImprovementDirection {
  String get string {
    switch (this) {
      case ImprovementDirection.positive:
        return tr.reportSection_type_improvementDirection_positive;
      case ImprovementDirection.negative:
        return tr.reportSection_type_improvementDirection_negative;
      default:
        return "[Invalid ImprovementDirection]";
    }
  }

  IconData? get icon {
    switch (this) {
      case ImprovementDirection.positive:
        return Icons.arrow_upward_rounded;
      case ImprovementDirection.negative:
        return Icons.arrow_downward_rounded;
      default:
        return null;
    }
  }
}