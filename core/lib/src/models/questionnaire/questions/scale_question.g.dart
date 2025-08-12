// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'scale_question.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ScaleQuestion _$ScaleQuestionFromJson(Map<String, dynamic> json) =>
    ScaleQuestion()
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
      ..initial = (json['initial'] as num).toDouble()
      ..annotations = (json['annotations'] as List<dynamic>)
          .map((e) => Annotation.fromJson(e as Map<String, dynamic>))
          .toList()
      ..minColor = (json['min_color'] as num?)?.toInt()
      ..maxColor = (json['max_color'] as num?)?.toInt()
      ..step = (json['step'] as num).toDouble();

Map<String, dynamic> _$ScaleQuestionToJson(ScaleQuestion instance) =>
    <String, dynamic>{
      'type': instance.type,
      'id': instance.id,
      if (instance.prompt case final value?) 'prompt': value,
      if (instance.rationale case final value?) 'rationale': value,
      if (instance.conditional?.toJson() case final value?)
        'conditional': value,
      'minimum': instance.minimum,
      'maximum': instance.maximum,
      'initial': instance.initial,
      'annotations': instance.annotations.map((e) => e.toJson()).toList(),
      if (instance.minColor case final value?) 'min_color': value,
      if (instance.maxColor case final value?) 'max_color': value,
      'step': instance.step,
    };
