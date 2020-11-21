// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'study_schedule.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

StudySchedule _$StudyScheduleFromJson(Map<String, dynamic> json) {
  return StudySchedule()
    ..numberOfCycles = json['numberOfCycles'] as int
    ..phaseDuration = json['phaseDuration'] as int
    ..includeBaseline = json['includeBaseline'] as bool
    ..sequence = _$enumDecode(_$PhaseSequenceEnumMap, json['sequence']);
}

Map<String, dynamic> _$StudyScheduleToJson(StudySchedule instance) =>
    <String, dynamic>{
      'numberOfCycles': instance.numberOfCycles,
      'phaseDuration': instance.phaseDuration,
      'includeBaseline': instance.includeBaseline,
      'sequence': _$PhaseSequenceEnumMap[instance.sequence],
    };

T _$enumDecode<T>(
  Map<T, dynamic> enumValues,
  dynamic source, {
  T unknownValue,
}) {
  if (source == null) {
    throw ArgumentError('A value must be provided. Supported values: '
        '${enumValues.values.join(', ')}');
  }

  final value = enumValues.entries
      .singleWhere((e) => e.value == source, orElse: () => null)
      ?.key;

  if (value == null && unknownValue == null) {
    throw ArgumentError('`$source` is not one of the supported values: '
        '${enumValues.values.join(', ')}');
  }
  return value ?? unknownValue;
}

const _$PhaseSequenceEnumMap = {
  PhaseSequence.alternating: 'alternating',
  PhaseSequence.counterBalanced: 'counterBalanced',
  PhaseSequence.randomized: 'randomized',
};
