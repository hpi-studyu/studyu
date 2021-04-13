import 'package:json_annotation/json_annotation.dart';

import '../../data/data_reference.dart';
import '../report_section.dart';
import '../temporal_aggregation.dart';

part 'average_section.g.dart';

@JsonSerializable()
class AverageSection extends ReportSection {
  static const String sectionType = 'average';

  TemporalAggregation? aggregate;
  late DataReference<num> resultProperty;

  AverageSection() : super(sectionType);

  AverageSection.withId() : super.withId(sectionType);

  factory AverageSection.fromJson(Map<String, dynamic> json) => _$AverageSectionFromJson(json);
  @override
  Map<String, dynamic> toJson() => _$AverageSectionToJson(this);
}
