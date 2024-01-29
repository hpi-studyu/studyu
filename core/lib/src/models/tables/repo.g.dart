// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'repo.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Repo _$RepoFromJson(Map<String, dynamic> json) => Repo(
      json['project_id'] as String,
      json['user_id'] as String,
      json['study_id'] as String,
      $enumDecode(_$GitProviderEnumMap, json['provider'],
          unknownValue: GitProvider.unknown),
      json['web_url'] as String?,
      json['git_url'] as String?,
    );

Map<String, dynamic> _$RepoToJson(Repo instance) {
  final val = <String, dynamic>{
    'project_id': instance.projectId,
    'user_id': instance.userId,
    'study_id': instance.studyId,
    'provider': _$GitProviderEnumMap[instance.provider]!,
  };

  void writeNotNull(String key, dynamic value) {
    if (value != null) {
      val[key] = value;
    }
  }

  writeNotNull('web_url', instance.webUrl);
  writeNotNull('git_url', instance.gitUrl);
  return val;
}

const _$GitProviderEnumMap = {
  GitProvider.unknown: 'unknown',
  GitProvider.gitlab: 'gitlab',
};
