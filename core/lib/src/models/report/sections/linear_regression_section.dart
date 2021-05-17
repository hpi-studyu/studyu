import 'package:json_annotation/json_annotation.dart';

import '../../data/data_reference.dart';
import '../report_section.dart';

part 'linear_regression_section.g.dart';

@JsonSerializable()
class LinearRegressionSection extends ReportSection {
  static const String sectionType = 'linearRegression';

  DataReference<num>? resultProperty;

  //TODO: Add model type enum, e.g. compare A vs B, compare A vs 0 and B, compare 0 vs A and B
  double alpha = 0.05;
  ImprovementDirection? improvement;

  LinearRegressionSection() : super(sectionType);

  LinearRegressionSection.withId() : super.withId(sectionType);

  factory LinearRegressionSection.fromJson(Map<String, dynamic> json) => _$LinearRegressionSectionFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$LinearRegressionSectionToJson(this);
}

enum ImprovementDirection {
  positive,
  negative,
}
