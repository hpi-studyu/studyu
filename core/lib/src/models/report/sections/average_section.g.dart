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

Map<String, dynamic> _$AverageSectionToJson(AverageSection instance) {
  final val = <String, dynamic>{
    'type': instance.type,
    'id': instance.id,
  };

  void writeNotNull(String key, dynamic value) {
    if (value != null) {
      val[key] = value;
    }
  }

  writeNotNull('title', instance.title);
  writeNotNull('description', instance.description);
  writeNotNull('aggregate', _$TemporalAggregationEnumMap[instance.aggregate]);
  writeNotNull('resultProperty', instance.resultProperty?.toJson());
  return val;
}

const _$TemporalAggregationEnumMap = {
  TemporalAggregation.day: 'day',
  TemporalAggregation.phase: 'phase',
  TemporalAggregation.intervention: 'intervention',
};
