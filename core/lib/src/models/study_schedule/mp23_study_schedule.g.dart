// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'mp23_study_schedule.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

MP23StudySchedule _$MP23StudyScheduleFromJson(Map<String, dynamic> json) =>
    MP23StudySchedule()
      ..segments = (json['segments'] as List<dynamic>)
          .map(
            (e) => const StudyScheduleSegmentConverter().fromJson(
              e as Map<String, dynamic>,
            ),
          )
          .toList();

Map<String, dynamic> _$MP23StudyScheduleToJson(MP23StudySchedule instance) =>
    <String, dynamic>{
      'segments': instance.segments
          .map(const StudyScheduleSegmentConverter().toJson)
          .toList(),
    };
