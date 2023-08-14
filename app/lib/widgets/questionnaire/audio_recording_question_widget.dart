import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:studyu_app/screens/study/multimodal/record_audio_screen.dart';
import 'package:studyu_core/core.dart';
import 'question_widget.dart';
import 'package:studyu_app/models/app_state.dart';

class AudioRecordingQuestionWidget extends QuestionWidget {
  final AudioRecordingQuestion question;
  final Function(Answer)? onDone;

  const AudioRecordingQuestionWidget(
      {Key? key, required this.question, this.onDone})
      : super(key: key);

  @override
  State<AudioRecordingQuestionWidget> createState() =>
      _AudioRecordingQuestionWidgetState();
}

class _AudioRecordingQuestionWidgetState
    extends State<AudioRecordingQuestionWidget> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    Future<void> recordAudio() async {
      final pathAnswer = await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => RecordAudioScreen(
              studyId: context.read<AppState>().activeSubject!.studyId,
              userId: context.read<AppState>().activeSubject!.userId,
            ),
          ));
      widget.onDone!(widget.question.constructAnswer(pathAnswer));
    }

    return Column(
      children: [
        TextButton(onPressed: recordAudio, child: const Text("Record now!")),
      ],
    );
  }
}
