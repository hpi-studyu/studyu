// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'counter_balanced_schedule_segment.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CounterBalancedScheduleSegment _$CounterBalancedScheduleSegmentFromJson(
  Map<String, dynamic> json,
) => CounterBalancedScheduleSegment(
  (json['interventionDuration'] as num).toInt(),
  (json['cycleAmount'] as num).toInt(),
  interventionIds: (json['interventionIds'] as List<dynamic>?)
      ?.map((e) => e as String)
      .toList(),
);

Map<String, dynamic> _$CounterBalancedScheduleSegmentToJson(
  CounterBalancedScheduleSegment instance,
) => <String, dynamic>{
  'type': instance.type.toJson(),
  'interventionDuration': instance.interventionDuration,
  'cycleAmount': instance.cycleAmount,
  'interventionIds': ?instance.interventionIds,
};
