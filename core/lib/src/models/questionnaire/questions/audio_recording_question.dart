import 'package:json_annotation/json_annotation.dart';
import 'package:studyu_core/core.dart';

import 'package:studyu_core/src/models/questionnaire/question_conditional.dart';

part 'audio_recording_question.g.dart';

@JsonSerializable()
class AudioRecordingQuestion extends Question<AudioRecordingQuestion> {
  static const String questionType = 'AudioRecordingQuestion';

  @JsonKey(name: 'maxRecordingDurationSeconds')
  final int maxRecordingDurationSeconds;

  AudioRecordingQuestion({required this.maxRecordingDurationSeconds}) : super(questionType);

  AudioRecordingQuestion.withId(this.maxRecordingDurationSeconds) : super.withId(questionType);

  factory AudioRecordingQuestion.fromJson(Map<String, dynamic> json) => _$AudioRecordingQuestionFromJson(json);
  @override
  Map<String, dynamic> toJson() => _$AudioRecordingQuestionToJson(this);

  Answer<FutureBlobFile> constructAnswer(FutureBlobFile response) => Answer.forQuestion(this, response);
}
