// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'linear_regression_section.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

LinearRegressionSection _$LinearRegressionSectionFromJson(Map<String, dynamic> json) => LinearRegressionSection()
  ..type = json['type'] as String
  ..id = json['id'] as String
  ..title = json['title'] as String?
  ..description = json['description'] as String?
  ..resultProperty =
      json['resultProperty'] == null ? null : DataReference.fromJson(json['resultProperty'] as Map<String, dynamic>)
  ..alpha = (json['alpha'] as num).toDouble()
  ..improvement = _$enumDecodeNullable(_$ImprovementDirectionEnumMap, json['improvement']);

Map<String, dynamic> _$LinearRegressionSectionToJson(LinearRegressionSection instance) {
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
  writeNotNull('resultProperty', instance.resultProperty?.toJson());
  val['alpha'] = instance.alpha;
  writeNotNull('improvement', _$ImprovementDirectionEnumMap[instance.improvement]);
  return val;
}

K _$enumDecode<K, V>(
  Map<K, V> enumValues,
  Object? source, {
  K? unknownValue,
}) {
  if (source == null) {
    throw ArgumentError(
      'A value must be provided. Supported values: '
      '${enumValues.values.join(', ')}',
    );
  }

  return enumValues.entries.singleWhere(
    (e) => e.value == source,
    orElse: () {
      if (unknownValue == null) {
        throw ArgumentError(
          '`$source` is not one of the supported values: '
          '${enumValues.values.join(', ')}',
        );
      }
      return MapEntry(unknownValue, enumValues.values.first);
    },
  ).key;
}

K? _$enumDecodeNullable<K, V>(
  Map<K, V> enumValues,
  dynamic source, {
  K? unknownValue,
}) {
  if (source == null) {
    return null;
  }
  return _$enumDecode<K, V>(enumValues, source, unknownValue: unknownValue);
}

const _$ImprovementDirectionEnumMap = {
  ImprovementDirection.positive: 'positive',
  ImprovementDirection.negative: 'negative',
};
