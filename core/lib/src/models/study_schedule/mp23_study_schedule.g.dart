// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'mp23_study_schedule.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

MP23StudySchedule _$MP23StudyScheduleFromJson(Map<String, dynamic> json) =>
    MP23StudySchedule()
      ..segments = (json['segments'] as List<dynamic>)
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
      (json['duration'] as num).toInt(),
    );

Map<String, dynamic> _$BaselineScheduleSegmentToJson(
        BaselineScheduleSegment instance) =>
    <String, dynamic>{
      'duration': instance.duration,
      'type': instance.type.toJson(),
    };

AlternatingScheduleSegment _$AlternatingScheduleSegmentFromJson(
        Map<String, dynamic> json) =>
    AlternatingScheduleSegment(
      (json['interventionDuration'] as num).toInt(),
      (json['cycleAmount'] as num).toInt(),
    );

Map<String, dynamic> _$AlternatingScheduleSegmentToJson(
        AlternatingScheduleSegment instance) =>
    <String, dynamic>{
      'type': instance.type.toJson(),
      'interventionDuration': instance.interventionDuration,
      'cycleAmount': instance.cycleAmount,
    };

ThompsonSamplingScheduleSegment _$ThompsonSamplingScheduleSegmentFromJson(
        Map<String, dynamic> json) =>
    ThompsonSamplingScheduleSegment(
      (json['interventionDuration'] as num).toInt(),
      (json['interventionDrawAmount'] as num).toInt(),
      json['observationId'] as String,
      json['questionId'] as String,
    );

Map<String, dynamic> _$ThompsonSamplingScheduleSegmentToJson(
        ThompsonSamplingScheduleSegment instance) =>
    <String, dynamic>{
      'type': instance.type.toJson(),
      'interventionDuration': instance.interventionDuration,
      'interventionDrawAmount': instance.interventionDrawAmount,
      'observationId': instance.observationId,
      'questionId': instance.questionId,
    };
