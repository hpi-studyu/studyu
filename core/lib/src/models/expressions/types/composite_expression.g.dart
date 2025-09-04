// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'composite_expression.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CompositeExpression _$CompositeExpressionFromJson(Map<String, dynamic> json) =>
    CompositeExpression(
      logicType: $enumDecode(_$LogicTypeEnumMap, json['logicType']),
      expressions: (json['expressions'] as List<dynamic>)
          .map((e) => Expression.fromJson(e as Map<String, dynamic>))
          .toList(),
    )..type = json['type'] as String?;

Map<String, dynamic> _$CompositeExpressionToJson(
  CompositeExpression instance,
) => <String, dynamic>{
  if (instance.type case final value?) 'type': value,
  'logicType': instance.logicType.toJson(),
  'expressions': instance.expressions.map((e) => e.toJson()).toList(),
};

const _$LogicTypeEnumMap = {LogicType.and: 'and', LogicType.or: 'or'};
