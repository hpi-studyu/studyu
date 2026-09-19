// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'medication_answer.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

MedicationAnswer _$MedicationAnswerFromJson(Map<String, dynamic> json) =>
    MedicationAnswer(
      medication: MedicationProductSnapshot.fromJson(
        json['medication'] as Map<String, dynamic>,
      ),
      quantity: json['quantity'] as num,
    );

Map<String, dynamic> _$MedicationAnswerToJson(MedicationAnswer instance) =>
    <String, dynamic>{
      'medication': instance.medication.toJson(),
      'quantity': instance.quantity,
    };
