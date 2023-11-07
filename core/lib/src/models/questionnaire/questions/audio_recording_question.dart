import 'package:json_annotation/json_annotation.dart';

import 'package:studyu_core/src/models/questionnaire/answer.dart';
import 'package:studyu_core/src/models/questionnaire/question.dart';
import 'package:studyu_core/src/models/questionnaire/question_conditional.dart';

part 'audio_recording_question.g.dart';

@JsonSerializable()
class AudioRecordingQuestion extends Question<AudioRecordingQuestion> {
  static const String questionType = 'AudioRecordingQuestion';

  AudioRecordingQuestion() : super(questionType);

  AudioRecordingQuestion.withId() : super.withId(questionType);

  factory AudioRecordingQuestion.fromJson(Map<String, dynamic> json) => _$AudioRecordingQuestionFromJson(json);
  @override
  Map<String, dynamic> toJson() => _$AudioRecordingQuestionToJson(this);

  Answer<String> constructAnswer(String response) => Answer.forQuestion(this, response);
}
