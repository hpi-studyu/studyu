// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'not_expression.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

NotExpression _$NotExpressionFromJson(Map<String, dynamic> json) =>
    NotExpression()
      ..type = json['type'] as String?
      ..expression = Expression.fromJson(
        json['expression'] as Map<String, dynamic>,
      );

Map<String, dynamic> _$NotExpressionToJson(NotExpression instance) =>
    <String, dynamic>{
      if (instance.type case final value?) 'type': value,
      'expression': instance.expression.toJson(),
    };
