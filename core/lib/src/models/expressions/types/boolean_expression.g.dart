// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'boolean_expression.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

BooleanExpression _$BooleanExpressionFromJson(Map<String, dynamic> json) =>
    BooleanExpression()
      ..type = json['type'] as String?
      ..target = json['target'] as String?;

Map<String, dynamic> _$BooleanExpressionToJson(BooleanExpression instance) =>
    <String, dynamic>{
      if (instance.type case final value?) 'type': value,
      if (instance.target case final value?) 'target': value,
    };
