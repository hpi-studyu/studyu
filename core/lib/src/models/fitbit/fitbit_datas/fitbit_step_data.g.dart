// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'fitbit_step_data.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

FitbitStepData _$FitbitStepDataFromJson(Map<String, dynamic> json) =>
    FitbitStepData(
      (json['value'] as num).toDouble(),
      DateTime.parse(json['dateTime'] as String),
    )..type = json['type'] as String;

Map<String, dynamic> _$FitbitStepDataToJson(FitbitStepData instance) =>
    <String, dynamic>{
      'type': instance.type,
      'dateTime': instance.dateTime.toIso8601String(),
      'value': instance.value,
    };
