// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'annotated_scale_question.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AnnotatedScaleQuestion _$AnnotatedScaleQuestionFromJson(
    Map<String, dynamic> json) {
  return AnnotatedScaleQuestion()
    ..type = json['type'] as String
    ..id = json['id'] as String
    ..prompt = json['prompt'] as String
    ..rationale = json['rationale'] as String
    ..minimum = (json['minimum'] as num).toDouble()
    ..maximum = (json['maximum'] as num).toDouble()
    ..initial = (json['initial'] as num).toDouble()
    ..step = (json['step'] as num)?.toDouble()
    ..annotations = (json['annotations'] as List)
        .map((e) => Annotation.fromJson(e as Map<String, dynamic>))
        .toList();
}

Map<String, dynamic> _$AnnotatedScaleQuestionToJson(
    AnnotatedScaleQuestion instance) {
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
  val['annotations'] = instance.annotations.map((e) => e.toJson()).toList();
  return val;
}

Annotation _$AnnotationFromJson(Map<String, dynamic> json) {
  return Annotation()
    ..value = json['value'] as int
    ..annotation = json['annotation'] as String;
}

Map<String, dynamic> _$AnnotationToJson(Annotation instance) =>
    <String, dynamic>{
      'value': instance.value,
      'annotation': instance.annotation,
    };
