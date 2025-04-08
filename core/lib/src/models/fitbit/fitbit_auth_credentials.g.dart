// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'fitbit_auth_credentials.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

FitbitAuthCredentials _$FitbitAuthCredentialsFromJson(
        Map<String, dynamic> json) =>
    FitbitAuthCredentials(
      clientId: json['clientId'] as String,
      clientSecret: json['clientSecret'] as String,
    );

Map<String, dynamic> _$FitbitAuthCredentialsToJson(
        FitbitAuthCredentials instance) =>
    <String, dynamic>{
      'clientId': instance.clientId,
      'clientSecret': instance.clientSecret,
    };
