// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'boolean_expression.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

BooleanExpression _$BooleanExpressionFromJson(Map<String, dynamic> json) =>
    BooleanExpression()
      ..type = json['type'] as String?
      ..target = json['target'] as String?;

Map<String, dynamic> _$BooleanExpressionToJson(BooleanExpression instance) {
  final val = <String, dynamic>{};

  void writeNotNull(String key, dynamic value) {
    if (value != null) {
      val[key] = value;
    }
  }

  writeNotNull('type', instance.type);
  writeNotNull('target', instance.target);
  return val;
}
