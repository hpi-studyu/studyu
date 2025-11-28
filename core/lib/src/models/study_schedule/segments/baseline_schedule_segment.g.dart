// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'baseline_schedule_segment.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

BaselineScheduleSegment _$BaselineScheduleSegmentFromJson(
  Map<String, dynamic> json,
) => BaselineScheduleSegment((json['duration'] as num).toInt());

Map<String, dynamic> _$BaselineScheduleSegmentToJson(
  BaselineScheduleSegment instance,
) => <String, dynamic>{
  'duration': instance.duration,
  'type': instance.type.toJson(),
};
