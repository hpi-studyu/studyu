// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'boolean_question.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

BooleanQuestion _$BooleanQuestionFromJson(Map<String, dynamic> json) {
  return BooleanQuestion()
    ..type = json['type'] as String
    ..id = json['id'] as String
    ..prompt = json['prompt'] as String
    ..rationale = json['rationale'] as String;
}

Map<String, dynamic> _$BooleanQuestionToJson(BooleanQuestion instance) {
  final val = <String, dynamic>{
    'type': instance.type,
    'id': instance.id,
    'prompt': instance.prompt,
  };

  void writeNotNull(String key, dynamic value) {
    if (value != null) {
      val[key] = value;
    }
  }

  writeNotNull('rationale', instance.rationale);
  return val;
}
