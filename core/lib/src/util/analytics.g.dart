// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'analytics.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

StudyUAnalytics _$StudyUAnalyticsFromJson(Map<String, dynamic> json) =>
    StudyUAnalytics(
      json['enabled'] as bool,
      json['dsn'] as String,
      (json['samplingRate'] as num?)?.toDouble(),
    );

Map<String, dynamic> _$StudyUAnalyticsToJson(StudyUAnalytics instance) =>
    <String, dynamic>{
      'enabled': instance.enabled,
      'dsn': instance.dsn,
      'samplingRate': instance.samplingRate,
    };
