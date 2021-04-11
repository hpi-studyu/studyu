import 'package:json_annotation/json_annotation.dart';

import 'intervention.dart';

part 'intervention_set.g.dart';

@JsonSerializable()
class InterventionSet {
  List<Intervention> interventions;

  InterventionSet(this.interventions);

  InterventionSet.designerDefault() : interventions = [];

  factory InterventionSet.fromJson(Map<String, dynamic> json) => _$InterventionSetFromJson(json);
  Map<String, dynamic> toJson() => _$InterventionSetToJson(this);
}
