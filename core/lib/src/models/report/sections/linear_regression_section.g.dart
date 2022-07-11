// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'linear_regression_section.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

LinearRegressionSection _$LinearRegressionSectionFromJson(
        Map<String, dynamic> json) =>
    LinearRegressionSection()
      ..type = json['type'] as String
      ..id = json['id'] as String
      ..title = json['title'] as String?
      ..description = json['description'] as String?
      ..resultProperty = json['resultProperty'] == null
          ? null
          : DataReference<num>.fromJson(
              json['resultProperty'] as Map<String, dynamic>)
      ..alpha = (json['alpha'] as num).toDouble()
      ..improvement = $enumDecodeNullable(
          _$ImprovementDirectionEnumMap, json['improvement']);

Map<String, dynamic> _$LinearRegressionSectionToJson(
    LinearRegressionSection instance) {
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
  writeNotNull(
      'improvement', _$ImprovementDirectionEnumMap[instance.improvement]);
  return val;
}

const _$ImprovementDirectionEnumMap = {
  ImprovementDirection.positive: 'positive',
  ImprovementDirection.negative: 'negative',
};
