// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'report_specification.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ReportSpecification _$ReportSpecificationFromJson(Map<String, dynamic> json) =>
    ReportSpecification()
      ..primary = json['primary'] == null
          ? null
          : ReportSection.fromJson(json['primary'] as Map<String, dynamic>)
      ..secondary = (json['secondary'] as List<dynamic>)
          .map((e) => ReportSection.fromJson(e as Map<String, dynamic>))
          .toList();

Map<String, dynamic> _$ReportSpecificationToJson(
        ReportSpecification instance) =>
    <String, dynamic>{
      'primary': instance.primary,
      'secondary': instance.secondary,
    };
