// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'report_specification.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ReportSpecification _$ReportSpecificationFromJson(Map<String, dynamic> json) {
  return ReportSpecification()
    ..primary = ReportSection.fromJson(json['primary'] as Map<String, dynamic>)
    ..secondary = (json['secondary'] as List)
        .map((e) => ReportSection.fromJson(e as Map<String, dynamic>))
        .toList();
}

Map<String, dynamic> _$ReportSpecificationToJson(
        ReportSpecification instance) =>
    <String, dynamic>{
      'primary': instance.primary.toJson(),
      'secondary': instance.secondary.map((e) => e.toJson()).toList(),
    };
