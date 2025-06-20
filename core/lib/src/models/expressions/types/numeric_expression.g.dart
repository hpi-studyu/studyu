// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'numeric_expression.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

NumericExpression _$NumericExpressionFromJson(Map<String, dynamic> json) =>
    NumericExpression(
      comparator: $enumDecode(_$NumericComparatorEnumMap, json['comparator']),
      value: json['value'] as num,
    )
      ..type = json['type'] as String?
      ..target = json['target'] as String?;

Map<String, dynamic> _$NumericExpressionToJson(NumericExpression instance) =>
    <String, dynamic>{
      if (instance.type case final value?) 'type': value,
      if (instance.target case final value?) 'target': value,
      'comparator': _$NumericComparatorEnumMap[instance.comparator]!,
      'value': instance.value,
    };

const _$NumericComparatorEnumMap = {
  NumericComparator.equal: '=',
  NumericComparator.notEqual: '!=',
  NumericComparator.greaterThan: '>',
  NumericComparator.lessThan: '<',
  NumericComparator.greaterThanOrEqual: '>=',
  NumericComparator.lessThanOrEqual: '<=',
};
