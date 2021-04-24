// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'repo.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Repo _$RepoFromJson(Map<String, dynamic> json) {
  return Repo(
    json['projectId'] as String,
    json['userId'] as String,
    json['studyId'] as String,
    _$enumDecode(_$GitProviderEnumMap, json['provider']),
  );
}

Map<String, dynamic> _$RepoToJson(Repo instance) => <String, dynamic>{
      'projectId': instance.projectId,
      'userId': instance.userId,
      'studyId': instance.studyId,
      'provider': _$GitProviderEnumMap[instance.provider],
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
