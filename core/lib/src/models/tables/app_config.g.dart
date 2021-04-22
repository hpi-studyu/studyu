// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_config.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AppConfig _$AppConfigFromJson(Map<String, dynamic> json) {
  return AppConfig(
    json['id'] as String,
    contact: Contact.fromJson(json['contact'] as Map<String, dynamic>),
    app_privacy: Map<String, String>.from(json['app_privacy'] as Map),
    app_terms: Map<String, String>.from(json['app_terms'] as Map),
    designer_privacy: Map<String, String>.from(json['designer_privacy'] as Map),
    designer_terms: Map<String, String>.from(json['designer_terms'] as Map),
    imprint: Map<String, String>.from(json['imprint'] as Map),
  );
}

Map<String, dynamic> _$AppConfigToJson(AppConfig instance) => <String, dynamic>{
      'id': instance.id,
      'contact': instance.contact.toJson(),
      'app_privacy': instance.app_privacy,
      'app_terms': instance.app_terms,
      'designer_privacy': instance.designer_privacy,
      'designer_terms': instance.designer_terms,
      'imprint': instance.imprint,
    };
