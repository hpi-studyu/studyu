// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'study_schedule.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

StudySchedule _$StudyScheduleFromJson(Map<String, dynamic> json) =>
    StudySchedule()
      ..numberOfCycles = json['numberOfCycles'] as int
      ..phaseDuration = json['phaseDuration'] as int
      ..includeBaseline = json['includeBaseline'] as bool
      ..sequence = $enumDecode(_$PhaseSequenceEnumMap, json['sequence']);

Map<String, dynamic> _$StudyScheduleToJson(StudySchedule instance) =>
    <String, dynamic>{
      'numberOfCycles': instance.numberOfCycles,
      'phaseDuration': instance.phaseDuration,
      'includeBaseline': instance.includeBaseline,
      'sequence': _$PhaseSequenceEnumMap[instance.sequence]!,
    };

const _$PhaseSequenceEnumMap = {
  PhaseSequence.alternating: 'alternating',
  PhaseSequence.counterBalanced: 'counterBalanced',
  PhaseSequence.randomized: 'randomized',
};
