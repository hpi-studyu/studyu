// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'adaptive_study_schedule.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AdaptiveStudySchedule _$AdaptiveStudyScheduleFromJson(
  Map<String, dynamic> json,
) => AdaptiveStudySchedule()
  ..segments = (json['segments'] as List<dynamic>)
      .map(
        (e) => const StudyScheduleSegmentConverter().fromJson(
          e as Map<String, dynamic>,
        ),
      )
      .toList();

Map<String, dynamic> _$AdaptiveStudyScheduleToJson(
  AdaptiveStudySchedule instance,
) => <String, dynamic>{
  'segments': instance.segments
      .map(const StudyScheduleSegmentConverter().toJson)
      .toList(),
};
