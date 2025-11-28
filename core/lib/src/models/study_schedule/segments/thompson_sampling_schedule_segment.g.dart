// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'thompson_sampling_schedule_segment.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ThompsonSamplingScheduleSegment _$ThompsonSamplingScheduleSegmentFromJson(
  Map<String, dynamic> json,
) => ThompsonSamplingScheduleSegment(
  (json['interventionDuration'] as num).toInt(),
  (json['interventionDrawAmount'] as num).toInt(),
  json['observationId'] as String,
  json['questionId'] as String,
);

Map<String, dynamic> _$ThompsonSamplingScheduleSegmentToJson(
  ThompsonSamplingScheduleSegment instance,
) => <String, dynamic>{
  'type': instance.type.toJson(),
  'interventionDuration': instance.interventionDuration,
  'interventionDrawAmount': instance.interventionDrawAmount,
  'observationId': instance.observationId,
  'questionId': instance.questionId,
};
