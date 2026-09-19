// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'medication_product_snapshot.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

MedicationProductSnapshot _$MedicationProductSnapshotFromJson(
  Map<String, dynamic> json,
) => MedicationProductSnapshot(
  pzn: json['pzn'] as String,
  officialName: json['officialName'] as String,
  activeIngredientCount: (json['activeIngredientCount'] as num).toInt(),
  dosageForm: MedicationDosageForm.fromJson(
    json['dosageForm'] as Map<String, dynamic>,
  ),
  components: (json['components'] as List<dynamic>)
      .map((e) => MedicationComponent.fromJson(e as Map<String, dynamic>))
      .toList(),
  source: MedicationSource.fromJson(json['source'] as Map<String, dynamic>),
);

Map<String, dynamic> _$MedicationProductSnapshotToJson(
  MedicationProductSnapshot instance,
) => <String, dynamic>{
  'pzn': instance.pzn,
  'officialName': instance.officialName,
  'activeIngredientCount': instance.activeIngredientCount,
  'dosageForm': instance.dosageForm.toJson(),
  'components': instance.components.map((e) => e.toJson()).toList(),
  'source': instance.source.toJson(),
};
