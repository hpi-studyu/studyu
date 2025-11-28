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
      .toList()
  ..numberOfInterventionsToSelect =
      (json['numberOfInterventionsToSelect'] as num?)?.toInt() ?? 2
  ..selectedInterventions =
      (json['selectedInterventions'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList() ??
      [];

Map<String, dynamic> _$AdaptiveStudyScheduleToJson(
  AdaptiveStudySchedule instance,
) => <String, dynamic>{
  'segments': instance.segments
      .map(const StudyScheduleSegmentConverter().toJson)
      .toList(),
  'numberOfInterventionsToSelect': instance.numberOfInterventionsToSelect,
  'selectedInterventions': instance.selectedInterventions,
};
