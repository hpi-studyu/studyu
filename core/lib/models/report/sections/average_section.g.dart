// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'average_section.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AverageSection _$AverageSectionFromJson(Map<String, dynamic> json) {
  return AverageSection()
    ..type = json['type'] as String
    ..id = json['id'] as String
    ..title = json['title'] as String
    ..description = json['description'] as String
    ..aggregate = _$enumDecode(_$TemporalAggregationEnumMap, json['aggregate'])
    ..resultProperty =
        DataReference.fromJson(json['resultProperty'] as Map<String, dynamic>);
}

Map<String, dynamic> _$AverageSectionToJson(AverageSection instance) =>
    <String, dynamic>{
      'type': instance.type,
      'id': instance.id,
      'title': instance.title,
      'description': instance.description,
      'aggregate': _$TemporalAggregationEnumMap[instance.aggregate],
      'resultProperty': instance.resultProperty.toJson(),
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

const _$TemporalAggregationEnumMap = {
  TemporalAggregation.day: 'day',
  TemporalAggregation.phase: 'phase',
  TemporalAggregation.intervention: 'intervention',
};
