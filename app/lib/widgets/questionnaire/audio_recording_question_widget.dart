import 'package:flutter/material.dart';
import 'package:studyu_app/widgets/questionnaire/capture_question_widget.dart';
import 'package:studyu_app/widgets/questionnaire/questions/question_widget.dart';
import 'package:studyu_core/core.dart';

class AudioRecordingQuestionWidget extends QuestionWidget {
  final AudioRecordingQuestion question;
  final Function(Answer)? onDone;

  const AudioRecordingQuestionWidget({super.key, required this.question, this.onDone});

  @override
  State<AudioRecordingQuestionWidget> createState() => _AudioRecordingQuestionWidgetState();
}

class _AudioRecordingQuestionWidgetState extends State<AudioRecordingQuestionWidget> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return CaptureQuestionWidget<AudioRecordingQuestion>(
      captureType: CaptureType.audio,
      question: widget.question,
      onDone: widget.onDone,
    );
  }
}
