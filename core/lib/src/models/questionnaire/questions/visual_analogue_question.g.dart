// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'visual_analogue_question.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

VisualAnalogueQuestion _$VisualAnalogueQuestionFromJson(
        Map<String, dynamic> json) =>
    VisualAnalogueQuestion()
      ..type = json['type'] as String
      ..id = json['id'] as String
      ..prompt = json['prompt'] as String?
      ..rationale = json['rationale'] as String?
      ..conditional = json['conditional'] == null
          ? null
          : QuestionConditional<num>.fromJson(
              json['conditional'] as Map<String, dynamic>)
      ..minimum = (json['minimum'] as num).toDouble()
      ..maximum = (json['maximum'] as num).toDouble()
      ..step = (json['step'] as num).toDouble()
      ..initial = (json['initial'] as num).toDouble()
      ..minimumColor = (json['minimumColor'] as num).toInt()
      ..maximumColor = (json['maximumColor'] as num).toInt()
      ..minimumAnnotation = json['minimumAnnotation'] as String
      ..maximumAnnotation = json['maximumAnnotation'] as String;

Map<String, dynamic> _$VisualAnalogueQuestionToJson(
    VisualAnalogueQuestion instance) {
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
  val['minimum'] = instance.minimum;
  val['maximum'] = instance.maximum;
  val['step'] = instance.step;
  val['initial'] = instance.initial;
  val['minimumColor'] = instance.minimumColor;
  val['maximumColor'] = instance.maximumColor;
  val['minimumAnnotation'] = instance.minimumAnnotation;
  val['maximumAnnotation'] = instance.maximumAnnotation;
  return val;
}
