// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'mp23_study_schedule.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

MP23StudySchedule _$MP23StudyScheduleFromJson(Map<String, dynamic> json) =>
    MP23StudySchedule(
      (json['interventions'] as List<dynamic>?)
              ?.map((e) => Intervention.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      (json['observations'] as List<dynamic>?)
              ?.map((e) => Observation.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    )..segments = (json['segments'] as List<dynamic>)
        .map((e) => const StudyScheduleSegmentConverter()
            .fromJson(e as Map<String, dynamic>))
        .toList();

Map<String, dynamic> _$MP23StudyScheduleToJson(MP23StudySchedule instance) =>
    <String, dynamic>{
      'segments': instance.segments
          .map(const StudyScheduleSegmentConverter().toJson)
          .toList(),
    };

BaselineScheduleSegment _$BaselineScheduleSegmentFromJson(
        Map<String, dynamic> json) =>
    BaselineScheduleSegment(
      json['duration'] as int,
    );

Map<String, dynamic> _$BaselineScheduleSegmentToJson(
        BaselineScheduleSegment instance) =>
    <String, dynamic>{
      'duration': instance.duration,
      'type': StudyScheduleSegmentType.toJson(instance.type),
    };

AlternatingScheduleSegment _$AlternatingScheduleSegmentFromJson(
        Map<String, dynamic> json) =>
    AlternatingScheduleSegment(
      json['interventionDuration'] as int,
      json['cycleAmount'] as int,
    );

Map<String, dynamic> _$AlternatingScheduleSegmentToJson(
        AlternatingScheduleSegment instance) =>
    <String, dynamic>{
      'type': StudyScheduleSegmentType.toJson(instance.type),
      'interventionDuration': instance.interventionDuration,
      'cycleAmount': instance.cycleAmount,
    };

ThompsonSamplingScheduleSegment _$ThompsonSamplingScheduleSegmentFromJson(
        Map<String, dynamic> json) =>
    ThompsonSamplingScheduleSegment(
      json['interventionDuration'] as int,
      json['interventionDrawAmount'] as int,
    );

Map<String, dynamic> _$ThompsonSamplingScheduleSegmentToJson(
        ThompsonSamplingScheduleSegment instance) =>
    <String, dynamic>{
      'type': StudyScheduleSegmentType.toJson(instance.type),
      'interventionDuration': instance.interventionDuration,
      'interventionDrawAmount': instance.interventionDrawAmount,
    };
