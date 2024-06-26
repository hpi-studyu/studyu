// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'image_capturing_question.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ImageCapturingQuestion _$ImageCapturingQuestionFromJson(
        Map<String, dynamic> json) =>
    ImageCapturingQuestion()
      ..type = json['type'] as String
      ..id = json['id'] as String
      ..prompt = json['prompt'] as String?
      ..rationale = json['rationale'] as String?
      ..conditional = json['conditional'] == null
          ? null
          : QuestionConditional<ImageCapturingQuestion>.fromJson(
              json['conditional'] as Map<String, dynamic>);

Map<String, dynamic> _$ImageCapturingQuestionToJson(
    ImageCapturingQuestion instance) {
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
  return val;
}
