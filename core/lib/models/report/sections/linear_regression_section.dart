import 'package:json_annotation/json_annotation.dart';

import '../../data/data_reference.dart';
import '../report_section.dart';

part 'linear_regression_section.g.dart';

@JsonSerializable()
class LinearRegressionSection extends ReportSection {
  static const String sectionType = 'linearRegression';

  DataReference<num> resultProperty;
  bool compareAB;
  double alpha;

  LinearRegressionSection() : super(sectionType);

  LinearRegressionSection.designerDefault()
      : alpha = 0.05,
        super.designer(sectionType);

  factory LinearRegressionSection.fromJson(Map<String, dynamic> json) => _$LinearRegressionSectionFromJson(json);
  @override
  Map<String, dynamic> toJson() => _$LinearRegressionSectionToJson(this);
}
