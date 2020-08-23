import 'package:json_annotation/json_annotation.dart';

import 'section.dart';

part 'report_specification.g.dart';

@JsonSerializable()
class ReportSpecification {
  Section primary;
  List<Section> secondary;

  ReportSpecification();

  factory ReportSpecification.fromJson(Map<String, dynamic> json) => _$ReportSpecificationFromJson(json);
  Map<String, dynamic> toJson() => _$ReportSpecificationToJson(this);
}
