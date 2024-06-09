// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'eligibility_criterion.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

EligibilityCriterion _$EligibilityCriterionFromJson(
        Map<String, dynamic> json) =>
    EligibilityCriterion(
      json['id'] as String,
    )
      ..reason = json['reason'] as String?
      ..condition =
          Expression.fromJson(json['condition'] as Map<String, dynamic>);

Map<String, dynamic> _$EligibilityCriterionToJson(
        EligibilityCriterion instance) =>
    <String, dynamic>{
      'id': instance.id,
      'reason': instance.reason,
      'condition': instance.condition,
    };
