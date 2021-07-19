// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'repo.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Repo _$RepoFromJson(Map<String, dynamic> json) => Repo(
      json['project_id'] as String,
      json['user_id'] as String,
      json['study_id'] as String,
      _$enumDecode(_$GitProviderEnumMap, json['provider']),
      json['web_url'] as String,
      json['git_url'] as String,
    );

Map<String, dynamic> _$RepoToJson(Repo instance) => <String, dynamic>{
      'project_id': instance.projectId,
      'user_id': instance.userId,
      'study_id': instance.studyId,
      'provider': _$GitProviderEnumMap[instance.provider],
      'web_url': instance.webUrl,
      'git_url': instance.gitUrl,
    };

K _$enumDecode<K, V>(
  Map<K, V> enumValues,
  Object? source, {
  K? unknownValue,
}) {
  if (source == null) {
    throw ArgumentError(
      'A value must be provided. Supported values: '
      '${enumValues.values.join(', ')}',
    );
  }

  return enumValues.entries.singleWhere(
    (e) => e.value == source,
    orElse: () {
      if (unknownValue == null) {
        throw ArgumentError(
          '`$source` is not one of the supported values: '
          '${enumValues.values.join(', ')}',
        );
      }
      return MapEntry(unknownValue, enumValues.values.first);
    },
  ).key;
}

const _$GitProviderEnumMap = {
  GitProvider.gitlab: 'gitlab',
};
