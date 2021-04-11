// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'fixed_schedule.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

FixedSchedule _$FixedScheduleFromJson(Map<String, dynamic> json) {
  return FixedSchedule()
    ..type = json['type'] as String
    ..time = Time.fromJson(json['time'] as String);
}

Map<String, dynamic> _$FixedScheduleToJson(FixedSchedule instance) =>
    <String, dynamic>{
      'type': instance.type,
      'time': instance.time.toJson(),
    };
