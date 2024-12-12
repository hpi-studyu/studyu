// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'result.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Result<T> _$ResultFromJson<T>(Map<String, dynamic> json) => Result<T>(
      json['type'] as String,
    )..periodId = json['periodId'] as String?;

Map<String, dynamic> _$ResultToJson<T>(Result<T> instance) => <String, dynamic>{
      'type': instance.type,
      if (instance.periodId case final value?) 'periodId': value,
    };
