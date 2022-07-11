// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'choice_question.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ChoiceQuestion _$ChoiceQuestionFromJson(Map<String, dynamic> json) =>
    ChoiceQuestion()
      ..type = json['type'] as String
      ..id = json['id'] as String
      ..prompt = json['prompt'] as String?
      ..rationale = json['rationale'] as String?
      ..conditional = json['conditional'] == null
          ? null
          : QuestionConditional<List<String>>.fromJson(
              json['conditional'] as Map<String, dynamic>)
      ..multiple = json['multiple'] as bool
      ..choices = (json['choices'] as List<dynamic>)
          .map((e) => Choice.fromJson(e as Map<String, dynamic>))
          .toList();

Map<String, dynamic> _$ChoiceQuestionToJson(ChoiceQuestion instance) {
  final val = <String, dynamic>{
    'type': instance.type,
    'id': instance.id,
  };

  void writeNotNull(String key, dynamic value) {
    if (value != null) {
      val[key] = value;
    }
  }

  writeNotNull('prompt', instance.prompt);
  writeNotNull('rationale', instance.rationale);
  writeNotNull('conditional', instance.conditional?.toJson());
  val['multiple'] = instance.multiple;
  val['choices'] = instance.choices.map((e) => e.toJson()).toList();
  return val;
}

Choice _$ChoiceFromJson(Map<String, dynamic> json) => Choice(
      json['id'] as String,
    )..text = json['text'] as String;

Map<String, dynamic> _$ChoiceToJson(Choice instance) => <String, dynamic>{
      'id': instance.id,
      'text': instance.text,
    };
