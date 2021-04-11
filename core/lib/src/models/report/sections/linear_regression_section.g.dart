// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'linear_regression_section.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

LinearRegressionSection _$LinearRegressionSectionFromJson(
    Map<String, dynamic> json) {
  return LinearRegressionSection()
    ..type = json['type'] as String
    ..id = json['id'] as String
    ..title = json['title'] as String
    ..description = json['description'] as String
    ..resultProperty =
        DataReference.fromJson(json['resultProperty'] as Map<String, dynamic>)
    ..alpha = (json['alpha'] as num).toDouble()
    ..improvement =
        _$enumDecode(_$ImprovementDirectionEnumMap, json['improvement']);
}

Map<String, dynamic> _$LinearRegressionSectionToJson(
        LinearRegressionSection instance) =>
    <String, dynamic>{
      'type': instance.type,
      'id': instance.id,
      'title': instance.title,
      'description': instance.description,
      'resultProperty': instance.resultProperty.toJson(),
      'alpha': instance.alpha,
      'improvement': _$ImprovementDirectionEnumMap[instance.improvement],
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

const _$ImprovementDirectionEnumMap = {
  ImprovementDirection.positive: 'positive',
  ImprovementDirection.negative: 'negative',
};
