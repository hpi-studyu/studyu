// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'medication_component.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

MedicationComponent _$MedicationComponentFromJson(Map<String, dynamic> json) =>
    MedicationComponent(
      key: json['key'] as String,
      number: (json['number'] as num).toInt(),
      dosageForm: MedicationDosageForm.fromJson(
        json['dosageForm'] as Map<String, dynamic>,
      ),
      description: json['description'] as String?,
      activeIngredients: (json['activeIngredients'] as List<dynamic>)
          .map(
            (e) =>
                MedicationActiveIngredient.fromJson(e as Map<String, dynamic>),
          )
          .toList(),
    );

Map<String, dynamic> _$MedicationComponentToJson(
  MedicationComponent instance,
) => <String, dynamic>{
  'key': instance.key,
  'number': instance.number,
  'dosageForm': instance.dosageForm.toJson(),
  'description': ?instance.description,
  'activeIngredients': instance.activeIngredients
      .map((e) => e.toJson())
      .toList(),
};
