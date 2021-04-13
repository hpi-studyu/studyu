// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'fixed_schedule.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

FixedSchedule _$FixedScheduleFromJson(Map<String, dynamic> json) {
  return FixedSchedule()
    ..type = json['type'] as String
    ..time = json['time'] == null
        ? null
        : ScheduleTime.fromJson(json['time'] as String);
}

Map<String, dynamic> _$FixedScheduleToJson(FixedSchedule instance) {
  final val = <String, dynamic>{
    'type': instance.type,
  };

  void writeNotNull(String key, dynamic value) {
    if (value != null) {
      val[key] = value;
    }
  }

  writeNotNull('time', instance.time?.toJson());
  return val;
}
