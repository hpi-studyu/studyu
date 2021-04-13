// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_config.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AppConfig _$AppConfigFromJson(Map<String, dynamic> json) {
  return AppConfig(
    contact: Contact.fromJson(json['contact'] as Map<String, dynamic>),
    app_privacy: Map<String, String>.from(json['app_privacy'] as Map),
    app_terms: Map<String, String>.from(json['app_terms'] as Map),
    designer_privacy: Map<String, String>.from(json['designer_privacy'] as Map),
    designer_terms: Map<String, String>.from(json['designer_terms'] as Map),
    imprint: Map<String, String>.from(json['imprint'] as Map),
  )..id = json['id'] as String?;
}

Map<String, dynamic> _$AppConfigToJson(AppConfig instance) {
  final val = <String, dynamic>{};

  void writeNotNull(String key, dynamic value) {
    if (value != null) {
      val[key] = value;
    }
  }

  writeNotNull('id', instance.id);
  val['contact'] = instance.contact.toJson();
  val['app_privacy'] = instance.app_privacy;
  val['app_terms'] = instance.app_terms;
  val['designer_privacy'] = instance.designer_privacy;
  val['designer_terms'] = instance.designer_terms;
  val['imprint'] = instance.imprint;
  return val;
}
