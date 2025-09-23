import 'package:json_annotation/json_annotation.dart';
import 'package:studyu_core/core.dart';

part 'gauge_comparison_section.g.dart';

@JsonSerializable()
class GaugeComparisonSection extends ReportSection {
  static const String sectionType = 'gauge_comparison';

  DataReference<num>? resultProperty;

  GaugeComparisonSection() : super(sectionType);

  GaugeComparisonSection.withId() : super.withId(sectionType);

  factory GaugeComparisonSection.fromJson(Map<String, dynamic> json) =>
      _$GaugeComparisonSectionFromJson(json);
  @override
  Map<String, dynamic> toJson() => _$GaugeComparisonSectionToJson(this);
}
