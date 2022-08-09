import 'package:json_annotation/json_annotation.dart';

import '../expressions/expression.dart';

part 'question_conditional.g.dart';

@JsonSerializable()
class QuestionConditional<V> {
  static const String keyDefaultValue = 'defaultValue';
  @JsonKey(ignore: true)
  V? defaultValue;
  late Expression condition;

  QuestionConditional();

  factory QuestionConditional.fromJson(Map<String, dynamic> json) => _fromJson(json);

  static QuestionConditional<V> _fromJson<K, V>(Map<String, dynamic> json) =>
      _$QuestionConditionalFromJson<V>(json)..defaultValue = json[keyDefaultValue] as V?;

  Map<String, dynamic> toJson() => _$QuestionConditionalToJson<V>(this)..[keyDefaultValue] = defaultValue;
}
