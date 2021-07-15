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
    EligibilityCriterion instance) {
  final val = <String, dynamic>{
    'id': instance.id,
  };

  void writeNotNull(String key, dynamic value) {
    if (value != null) {
      val[key] = value;
    }
  }

  writeNotNull('reason', instance.reason);
  val['condition'] = instance.condition.toJson();
  return val;
}
