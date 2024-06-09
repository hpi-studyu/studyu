// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'average_section.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AverageSection _$AverageSectionFromJson(Map<String, dynamic> json) =>
    AverageSection()
      ..type = json['type'] as String
      ..id = json['id'] as String
      ..title = json['title'] as String?
      ..description = json['description'] as String?
      ..aggregate =
          $enumDecodeNullable(_$TemporalAggregationEnumMap, json['aggregate'])
      ..resultProperty = json['resultProperty'] == null
          ? null
          : DataReference<num>.fromJson(
              json['resultProperty'] as Map<String, dynamic>);

Map<String, dynamic> _$AverageSectionToJson(AverageSection instance) =>
    <String, dynamic>{
      'type': instance.type,
      'id': instance.id,
      'title': instance.title,
      'description': instance.description,
      'aggregate': _$TemporalAggregationEnumMap[instance.aggregate],
      'resultProperty': instance.resultProperty,
    };

const _$TemporalAggregationEnumMap = {
  TemporalAggregation.day: 'day',
  TemporalAggregation.phase: 'phase',
  TemporalAggregation.intervention: 'intervention',
};
