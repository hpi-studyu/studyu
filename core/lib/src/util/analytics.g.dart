// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'logging.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

StudyUAnalytics _$StudyUAnalyticsFromJson(Map<String, dynamic> json) =>
    StudyUAnalytics(
      json['enabled'] as bool,
      json['dsn'] as String,
      (json['samplingRate'] as num?)?.toDouble(),
    );

Map<String, dynamic> _$StudyUAnalyticsToJson(StudyUAnalytics instance) {
  final val = <String, dynamic>{
    'enabled': instance.enabled,
    'dsn': instance.dsn,
  };

  void writeNotNull(String key, dynamic value) {
    if (value != null) {
      val[key] = value;
    }
  }

  writeNotNull('samplingRate', instance.samplingRate);
  return val;
}
