// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'medication_dosage_form.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

MedicationDosageForm _$MedicationDosageFormFromJson(
  Map<String, dynamic> json,
) => MedicationDosageForm(
  patientFriendlyShort: json['patientFriendlyShort'] as String?,
  patientFriendlyLong: json['patientFriendlyLong'] as String?,
  bfarmName: json['bfarmName'] as String?,
  bfarmTermId: json['bfarmTermId'] as String?,
);

Map<String, dynamic> _$MedicationDosageFormToJson(
  MedicationDosageForm instance,
) => <String, dynamic>{
  'patientFriendlyShort': ?instance.patientFriendlyShort,
  'patientFriendlyLong': ?instance.patientFriendlyLong,
  'bfarmName': ?instance.bfarmName,
  'bfarmTermId': ?instance.bfarmTermId,
};
