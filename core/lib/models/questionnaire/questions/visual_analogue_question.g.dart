// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'visual_analogue_question.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

VisualAnalogueQuestion _$VisualAnalogueQuestionFromJson(
    Map<String, dynamic> json) {
  return VisualAnalogueQuestion()
    ..type = json['type'] as String
    ..id = json['id'] as String
    ..prompt = json['prompt'] as String
    ..rationale = json['rationale'] as String
    ..minimum = (json['minimum'] as num).toDouble()
    ..maximum = (json['maximum'] as num).toDouble()
    ..initial = (json['initial'] as num).toDouble()
    ..step = (json['step'] as num)?.toDouble()
    ..minimumColor =
        VisualAnalogueQuestion.parseColor(json['minimumColor'] as String)
    ..maximumColor =
        VisualAnalogueQuestion.parseColor(json['maximumColor'] as String)
    ..minimumAnnotation = json['minimumAnnotation'] as String
    ..maximumAnnotation = json['maximumAnnotation'] as String;
}

Map<String, dynamic> _$VisualAnalogueQuestionToJson(
    VisualAnalogueQuestion instance) {
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
  val['minimum'] = instance.minimum;
  val['maximum'] = instance.maximum;
  val['initial'] = instance.initial;
  writeNotNull('step', instance.step);
  writeNotNull('minimumColor',
      VisualAnalogueQuestion.colorToJson(instance.minimumColor));
  writeNotNull('maximumColor',
      VisualAnalogueQuestion.colorToJson(instance.maximumColor));
  val['minimumAnnotation'] = instance.minimumAnnotation;
  val['maximumAnnotation'] = instance.maximumAnnotation;
  return val;
}
