// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

StudyUUser _$StudyUUserFromJson(Map<String, dynamic> json) => StudyUUser(
      id: json['id'] as String,
      email: json['email'] as String,
      preferences: json['preferences'] == null
          ? null
          : Preferences.fromJson(json['preferences'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$StudyUUserToJson(StudyUUser instance) =>
    <String, dynamic>{
      'id': instance.id,
      'email': instance.email,
      'preferences': instance.preferences.toJson(),
    };

Preferences _$PreferencesFromJson(Map<String, dynamic> json) => Preferences(
      language: json['lang'] as String? ?? '',
      pinnedStudies: (json['pinned_studies'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toSet() ??
          const {},
    );

Map<String, dynamic> _$PreferencesToJson(Preferences instance) =>
    <String, dynamic>{
      'lang': instance.language,
      'pinned_studies': instance.pinnedStudies.toList(),
    };
