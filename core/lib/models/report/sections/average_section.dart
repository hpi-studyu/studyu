import 'package:json_annotation/json_annotation.dart';

import '../../data/data_reference.dart';
import '../section.dart';
import '../temporal_aggregation.dart';

part 'average_section.g.dart';

@JsonSerializable()
class AverageSection extends Section {
  static const String sectionType = 'average';

  TemporalAggregation aggregate;
  DataReference<num> resultProperty;

  AverageSection() : super(sectionType);

  factory AverageSection.fromJson(Map<String, dynamic> json) => _$AverageSectionFromJson(json);
  @override
  Map<String, dynamic> toJson() => _$AverageSectionToJson(this);
}
