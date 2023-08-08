import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:studyu_app/screens/study/multimodal/capture_picture_screen.dart';
import 'package:studyu_core/core.dart';
import 'question_widget.dart';
import 'package:studyu_app/models/app_state.dart';

class ImageCapturingQuestionWidget extends QuestionWidget {
  final ImageCapturingQuestion question;
  final Function(Answer)? onDone;

  const ImageCapturingQuestionWidget(
      {Key? key, required this.question, this.onDone})
      : super(key: key);

  @override
  State<ImageCapturingQuestionWidget> createState() =>
      _ImageCapturingQuestionWidgetState();
}

class _ImageCapturingQuestionWidgetState
    extends State<ImageCapturingQuestionWidget> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    Future<void> captureImage() async {
      final pathAnswer = await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => CapturePictureScreen(
              studyId: context.read<AppState>().activeSubject!.studyId,
              userId: context.read<AppState>().activeSubject!.userId,
            ),
          ));
      widget.onDone!(widget.question.constructAnswer(pathAnswer));
    }

    return Column(
      children: [
        TextButton(onPressed: captureImage, child: const Text("Capture!")),
      ],
    );
  }
}
