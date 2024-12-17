// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'fitbit_question.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

FitbitQuestion _$FitbitQuestionFromJson(Map<String, dynamic> json) =>
    FitbitQuestion(
      types: (json['types'] as List<dynamic>)
          .map((e) => $enumDecode(_$FitbitQuestionTypeEnumMap, e))
          .toList(),
    )
      ..type = json['type'] as String
      ..id = json['id'] as String
      ..prompt = json['prompt'] as String?
      ..rationale = json['rationale'] as String?
      ..conditional = json['conditional'] == null
          ? null
          : QuestionConditional<FitbitQuestion>.fromJson(
              json['conditional'] as Map<String, dynamic>);

Map<String, dynamic> _$FitbitQuestionToJson(FitbitQuestion instance) {
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
  val['types'] = instance.types.map((e) => e.toJson()).toList();
  return val;
}

const _$FitbitQuestionTypeEnumMap = {
  FitbitQuestionType.heartrate: 'heartrate',
  FitbitQuestionType.sleep: 'sleep',
  FitbitQuestionType.steps: 'steps',
};
