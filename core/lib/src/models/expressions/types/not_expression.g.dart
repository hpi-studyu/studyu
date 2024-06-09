// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'not_expression.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

NotExpression _$NotExpressionFromJson(Map<String, dynamic> json) =>
    NotExpression()
      ..type = json['type'] as String?
      ..expression =
          Expression.fromJson(json['expression'] as Map<String, dynamic>);

Map<String, dynamic> _$NotExpressionToJson(NotExpression instance) {
  final val = <String, dynamic>{};

  void writeNotNull(String key, dynamic value) {
    if (value != null) {
      val[key] = value;
    }
  }

  writeNotNull('type', instance.type);
  val['expression'] = instance.expression.toJson();
  return val;
}
