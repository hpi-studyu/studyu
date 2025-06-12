// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'text_expression.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TextExpression _$TextExpressionFromJson(Map<String, dynamic> json) =>
    TextExpression(
      comparator: $enumDecode(_$TextComparatorEnumMap, json['comparator']),
      value: json['value'] as String,
    )
      ..type = json['type'] as String?
      ..target = json['target'] as String?;

Map<String, dynamic> _$TextExpressionToJson(TextExpression instance) =>
    <String, dynamic>{
      if (instance.type case final value?) 'type': value,
      if (instance.target case final value?) 'target': value,
      'comparator': _$TextComparatorEnumMap[instance.comparator]!,
      'value': instance.value,
    };

const _$TextComparatorEnumMap = {
  TextComparator.equal: '=',
  TextComparator.notEqual: '!=',
  TextComparator.contains: 'contains',
  TextComparator.doesNotContain: 'does_not_contain',
};
