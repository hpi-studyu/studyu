import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:studyu_app/screens/study/multimodal/capture_picture_screen.dart';
import 'package:studyu_app/widgets/questionnaire/capture_question_widget.dart';
import 'package:studyu_core/core.dart';
import 'question_widget.dart';
import 'package:studyu_app/models/app_state.dart';

class ImageCapturingQuestionWidget extends QuestionWidget {
  final ImageCapturingQuestion question;
  final Function(Answer)? onDone;

  const ImageCapturingQuestionWidget({super.key, required this.question, this.onDone});

  @override
  State<ImageCapturingQuestionWidget> createState() => _ImageCapturingQuestionWidgetState();
}

class _ImageCapturingQuestionWidgetState extends State<ImageCapturingQuestionWidget> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return CaptureQuestionWidget<ImageCapturingQuestion>(
      captureType: CaptureType.image,
      question: widget.question,
      onDone: widget.onDone,
    );
  }
}
