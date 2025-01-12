// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'fitbit_sleep_data.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

FitbitSleepData _$FitbitSleepDataFromJson(Map<String, dynamic> json) =>
    FitbitSleepData(
      json['level'] as String,
      DateTime.parse(json['entryDateTime'] as String),
      DateTime.parse(json['dateTime'] as String),
    )..type = json['type'] as String;

Map<String, dynamic> _$FitbitSleepDataToJson(FitbitSleepData instance) =>
    <String, dynamic>{
      'type': instance.type,
      'dateTime': instance.dateTime.toIso8601String(),
      'level': instance.level,
      'entryDateTime': instance.entryDateTime.toIso8601String(),
    };
