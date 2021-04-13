// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'intervention_set.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

InterventionSet _$InterventionSetFromJson(Map<String, dynamic> json) {
  return InterventionSet(
    (json['interventions'] as List<dynamic>)
        .map((e) => Intervention.fromJson(e as Map<String, dynamic>))
        .toList(),
  );
}

Map<String, dynamic> _$InterventionSetToJson(InterventionSet instance) =>
    <String, dynamic>{
      'interventions': instance.interventions.map((e) => e.toJson()).toList(),
    };
