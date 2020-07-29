import 'package:json_annotation/json_annotation.dart';

import '../expressions/expression.dart';
import 'answer.dart';

part 'question_conditional.g.dart';

@JsonSerializable()
class QuestionConditional<V> {
  Answer<V> defaultValue;
  Expression condition;

  static QuestionConditional<V> fromJson<V>(Map<String, dynamic> json) => _$QuestionConditionalFromJson<V>(json);
  Map<String, dynamic> toJson() => _$QuestionConditionalToJson<V>(this);
}
