import 'package:json_annotation/json_annotation.dart';

import 'intervention.dart';

part 'intervention_set.g.dart';

@JsonSerializable()
class InverventionSet {
  List<Intervention> interventions;

  InverventionSet(this.interventions);

  factory InverventionSet.fromJson(Map<String, dynamic> json) => _$InverventionSetFromJson(json);
  Map<String, dynamic> toJson() => _$InverventionSetToJson(this);
}
