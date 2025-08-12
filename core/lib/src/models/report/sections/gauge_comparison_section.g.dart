// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'gauge_comparison_section.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

GaugeComparisonSection _$GaugeComparisonSectionFromJson(
        Map<String, dynamic> json) =>
    GaugeComparisonSection()
      ..type = json['type'] as String
      ..id = json['id'] as String
      ..title = json['title'] as String?
      ..description = json['description'] as String?
      ..resultProperty = json['resultProperty'] == null
          ? null
          : DataReference<num>.fromJson(
              json['resultProperty'] as Map<String, dynamic>);

Map<String, dynamic> _$GaugeComparisonSectionToJson(
        GaugeComparisonSection instance) =>
    <String, dynamic>{
      'type': instance.type,
      'id': instance.id,
      if (instance.title case final value?) 'title': value,
      if (instance.description case final value?) 'description': value,
      if (instance.resultProperty?.toJson() case final value?)
        'resultProperty': value,
    };
