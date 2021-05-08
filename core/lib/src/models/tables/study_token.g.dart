// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'study_token.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

StudyToken _$StudyTokenFromJson(Map<String, dynamic> json) {
  return StudyToken(
    json['token'] as String,
    json['studyId'] as String,
  );
}

Map<String, dynamic> _$StudyTokenToJson(StudyToken instance) =>
    <String, dynamic>{
      'token': instance.token,
      'studyId': instance.studyId,
    };
