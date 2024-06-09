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
        AudioRecordingQuestion instance) =>
    <String, dynamic>{
      'type': instance.type,
      'id': instance.id,
      'prompt': instance.prompt,
      'rationale': instance.rationale,
      'conditional': instance.conditional,
      'maxRecordingDurationSeconds': instance.maxRecordingDurationSeconds,
    };
