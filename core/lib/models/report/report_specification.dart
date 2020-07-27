import 'package:json_annotation/json_annotation.dart';

import 'outcomes/outcome.dart';

part 'report_specification.g.dart';

@JsonSerializable()
class ReportSpecification {
  double significanceLevel;

  List<Outcome> outcomes;

  ReportSpecification();

  factory ReportSpecification.fromJson(Map<String, dynamic> json) => _$ReportSpecificationFromJson(json);
  Map<String, dynamic> toJson() => _$ReportSpecificationToJson(this);
}
