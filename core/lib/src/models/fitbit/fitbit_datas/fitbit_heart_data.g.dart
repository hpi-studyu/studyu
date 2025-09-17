// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'fitbit_heart_data.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

FitbitHeartData _$FitbitHeartDataFromJson(Map<String, dynamic> json) =>
    FitbitHeartData(
      (json['value'] as num).toDouble(),
      DateTime.parse(json['dateTime'] as String),
    )..type = json['type'] as String;

Map<String, dynamic> _$FitbitHeartDataToJson(FitbitHeartData instance) =>
    <String, dynamic>{
      'type': instance.type,
      'dateTime': instance.dateTime.toIso8601String(),
      'value': instance.value,
    };
