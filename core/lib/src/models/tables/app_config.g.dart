// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_config.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AppConfig _$AppConfigFromJson(Map<String, dynamic> json) => AppConfig(
      json['id'] as String,
      appMinVersion: json['app_min_version'] as String,
      appPrivacy: Map<String, String>.from(json['app_privacy'] as Map),
      appTerms: Map<String, String>.from(json['app_terms'] as Map),
      designerPrivacy:
          Map<String, String>.from(json['designer_privacy'] as Map),
      designerTerms: Map<String, String>.from(json['designer_terms'] as Map),
      contact: Contact.fromJson(json['contact'] as Map<String, dynamic>),
      imprint: Map<String, String>.from(json['imprint'] as Map),
      analytics: json['analytics'] == null
          ? null
          : StudyUAnalytics.fromJson(json['analytics'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$AppConfigToJson(AppConfig instance) {
  final val = <String, dynamic>{
    'id': instance.id,
    'app_min_version': instance.appMinVersion,
    'app_privacy': instance.appPrivacy,
    'app_terms': instance.appTerms,
    'designer_privacy': instance.designerPrivacy,
    'designer_terms': instance.designerTerms,
    'imprint': instance.imprint,
    'contact': instance.contact.toJson(),
  };

  void writeNotNull(String key, dynamic value) {
    if (value != null) {
      val[key] = value;
    }
  }

  writeNotNull('analytics', instance.analytics?.toJson());
  return val;
}
