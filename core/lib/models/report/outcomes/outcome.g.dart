// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'outcome.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Outcome _$OutcomeFromJson(Map<String, dynamic> json) {
  return Outcome()
    ..outcomeId = json['outcomeId'] as String
    ..title = json['title'] as String
    ..description = json['description'] as String
    ..chartType = _$enumDecode(_$ChartTypeEnumMap, json['chartType'])
    ..chartX = _$enumDecode(_$ChartXEnumMap, json['chartX'])
    ..taskId = json['taskId'] as String
    ..questionId = json['questionId'] as String;
}

Map<String, dynamic> _$OutcomeToJson(Outcome instance) => <String, dynamic>{
      'outcomeId': instance.outcomeId,
      'title': instance.title,
      'description': instance.description,
      'chartType': _$ChartTypeEnumMap[instance.chartType],
      'chartX': _$ChartXEnumMap[instance.chartX],
      'taskId': instance.taskId,
      'questionId': instance.questionId,
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

const _$ChartTypeEnumMap = {
  ChartType.BAR: 'BAR',
  ChartType.LINE: 'LINE',
};

const _$ChartXEnumMap = {
  ChartX.DATE: 'DATE',
  ChartX.INTERVENTION: 'INTERVENTION',
};
