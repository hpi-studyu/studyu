// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'medication_active_ingredient.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

MedicationActiveIngredient _$MedicationActiveIngredientFromJson(
  Map<String, dynamic> json,
) => MedicationActiveIngredient(
  key: json['key'] as String,
  name: json['name'] as String,
  strength: json['strength'] as String?,
  bfarmSubstanceId: json['bfarmSubstanceId'] as String?,
  rank: (json['rank'] as num).toInt(),
);

Map<String, dynamic> _$MedicationActiveIngredientToJson(
  MedicationActiveIngredient instance,
) => <String, dynamic>{
  'key': instance.key,
  'name': instance.name,
  'strength': ?instance.strength,
  'bfarmSubstanceId': ?instance.bfarmSubstanceId,
  'rank': instance.rank,
};
