// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'annotated_scale_question.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AnnotatedScaleQuestion _$AnnotatedScaleQuestionFromJson(
        Map<String, dynamic> json) =>
    AnnotatedScaleQuestion()
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
      ..annotations = (json['annotations'] as List<dynamic>)
          .map((e) => Annotation.fromJson(e as Map<String, dynamic>))
          .toList();

Map<String, dynamic> _$AnnotatedScaleQuestionToJson(
    AnnotatedScaleQuestion instance) {
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
  val['annotations'] = instance.annotations.map((e) => e.toJson()).toList();
  return val;
}

Annotation _$AnnotationFromJson(Map<String, dynamic> json) => Annotation()
  ..value = (json['value'] as num).toInt()
  ..annotation = json['annotation'] as String;

Map<String, dynamic> _$AnnotationToJson(Annotation instance) =>
    <String, dynamic>{
      'value': instance.value,
      'annotation': instance.annotation,
    };
