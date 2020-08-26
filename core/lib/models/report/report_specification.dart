import 'package:json_annotation/json_annotation.dart';

import 'report_section.dart';

part 'report_specification.g.dart';

@JsonSerializable()
class ReportSpecification {
  @JsonKey(nullable: true)
  ReportSection primary;
  List<ReportSection> secondary;

  ReportSpecification() : secondary = [];

  factory ReportSpecification.fromJson(Map<String, dynamic> json) => _$ReportSpecificationFromJson(json);
  Map<String, dynamic> toJson() => _$ReportSpecificationToJson(this);
}
