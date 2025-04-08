// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'study_fitbit_credentials.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

StudyFitbitCredentials _$StudyFitbitCredentialsFromJson(
        Map<String, dynamic> json) =>
    StudyFitbitCredentials(
      json['study_id'] as String,
      FitbitAuthCredentials.fromJson(
          json['fitbit_credentials'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$StudyFitbitCredentialsToJson(
        StudyFitbitCredentials instance) =>
    <String, dynamic>{
      'study_id': instance.studyId,
      'fitbit_credentials': instance.fitbitCredentials.toJson(),
    };
