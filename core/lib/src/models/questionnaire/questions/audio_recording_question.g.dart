// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'audio_recording_question.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AudioRecordingQuestion _$AudioRecordingQuestionFromJson(
        Map<String, dynamic> json) =>
    AudioRecordingQuestion(
      maxRecordingDurationSeconds:
          (json['maxRecordingDurationSeconds'] as num).toInt(),
    )
      ..type = json['type'] as String
      ..id = json['id'] as String
      ..prompt = json['prompt'] as String?
      ..rationale = json['rationale'] as String?
      ..conditional = json['conditional'] == null
          ? null
          : QuestionConditional<AudioRecordingQuestion>.fromJson(
              json['conditional'] as Map<String, dynamic>);

Map<String, dynamic> _$AudioRecordingQuestionToJson(
    AudioRecordingQuestion instance) {
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
  val['maxRecordingDurationSeconds'] = instance.maxRecordingDurationSeconds;
  return val;
}
