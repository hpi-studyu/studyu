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
    ..compareAB = json['compareAB'] as bool
    ..alpha = (json['alpha'] as num).toDouble();
}

Map<String, dynamic> _$LinearRegressionSectionToJson(
        LinearRegressionSection instance) =>
    <String, dynamic>{
      'type': instance.type,
      'id': instance.id,
      'title': instance.title,
      'description': instance.description,
      'resultProperty': instance.resultProperty.toJson(),
      'compareAB': instance.compareAB,
      'alpha': instance.alpha,
    };
