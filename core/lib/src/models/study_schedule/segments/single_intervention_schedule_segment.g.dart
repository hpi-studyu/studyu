// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'single_intervention_schedule_segment.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SingleInterventionScheduleSegment _$SingleInterventionScheduleSegmentFromJson(
  Map<String, dynamic> json,
) => SingleInterventionScheduleSegment(
  (json['interventionIndex'] as num).toInt(),
  (json['duration'] as num).toInt(),
);

Map<String, dynamic> _$SingleInterventionScheduleSegmentToJson(
  SingleInterventionScheduleSegment instance,
) => <String, dynamic>{
  'type': instance.type.toJson(),
  'interventionIndex': instance.interventionIndex,
  'duration': instance.duration,
};
