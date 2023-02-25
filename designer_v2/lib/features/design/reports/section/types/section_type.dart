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
        return 'tr.reportSection_type_average';
      case ReportSectionType.linearRegression:
        return 'tr.reportSection_type_linearRegression';
      default:
        return "[Invalid ReportSectionType]";
    }
  }

  IconData? get icon {
    switch (this) {
      case ReportSectionType.average:
        // todo
        return Icons.format_list_bulleted_rounded;
      case ReportSectionType.linearRegression:
        // todo
        return Icons.tune_rounded;
      default:
        return null;
    }
  }

  String toJson() => name;
  static ReportSectionType fromJson(String json) => values.byName(json);
}
