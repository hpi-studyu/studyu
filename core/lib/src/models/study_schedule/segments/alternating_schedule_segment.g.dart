// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'alternating_schedule_segment.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AlternatingScheduleSegment _$AlternatingScheduleSegmentFromJson(
  Map<String, dynamic> json,
) => AlternatingScheduleSegment(
  (json['interventionDuration'] as num).toInt(),
  (json['cycleAmount'] as num).toInt(),
  interventionIds: (json['interventionIds'] as List<dynamic>?)
      ?.map((e) => (e as num).toInt())
      .toList(),
);

Map<String, dynamic> _$AlternatingScheduleSegmentToJson(
  AlternatingScheduleSegment instance,
) => <String, dynamic>{
  'type': instance.type.toJson(),
  'interventionDuration': instance.interventionDuration,
  'cycleAmount': instance.cycleAmount,
  'interventionIds': ?instance.interventionIds,
};
