import 'package:flutter/material.dart';
import 'package:studyu_app/screens/study/multimodal/capture_picture_screen.dart';
import 'package:studyu_core/core.dart';
import 'question_widget.dart';

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
    Future<void> captureImageCallback(String aResultText) async {
      widget.onDone!(widget.question.constructAnswer(aResultText));
    }

    return Column(
      children: [
        TextButton(
            onPressed: () async => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      CapturePictureScreen(pathCallback: captureImageCallback),
                )),
            child: const Text("Capture!")),
      ],
    );
  }
}
