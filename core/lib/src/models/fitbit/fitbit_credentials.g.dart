// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'fitbit_credentials.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

FitbitCredentials _$FitbitCredentialsFromJson(Map<String, dynamic> json) =>
    FitbitCredentials(
      clientId: json['clientId'] as String,
      clientSecret: json['clientSecret'] as String,
    );

Map<String, dynamic> _$FitbitCredentialsToJson(FitbitCredentials instance) =>
    <String, dynamic>{
      'clientId': instance.clientId,
      'clientSecret': instance.clientSecret,
    };
