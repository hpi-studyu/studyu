// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'report_specification.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ReportSpecification _$ReportSpecificationFromJson(Map<String, dynamic> json) {
  return ReportSpecification()
    ..significanceLevel = (json['significanceLevel'] as num).toDouble()
    ..outcomes = (json['outcomes'] as List)
        .map((e) => Outcome.fromJson(e as Map<String, dynamic>))
        .toList();
}

Map<String, dynamic> _$ReportSpecificationToJson(
        ReportSpecification instance) =>
    <String, dynamic>{
      'significanceLevel': instance.significanceLevel,
      'outcomes': instance.outcomes.map((e) => e.toJson()).toList(),
    };
