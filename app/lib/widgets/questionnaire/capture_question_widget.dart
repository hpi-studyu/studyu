import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:provider/provider.dart';
import 'package:studyu_app/screens/study/multimodal/capture_picture_screen.dart';
import 'package:studyu_app/screens/study/multimodal/record_audio_screen.dart';
import 'package:studyu_core/core.dart';
import 'question_widget.dart';
import 'package:studyu_app/models/app_state.dart';

enum CaptureType {
  image,
  audio,
}

class CaptureQuestionWidget<T> extends QuestionWidget {
  final CaptureType captureType;
  final T question;
  final Function(Answer)? onDone;

  const CaptureQuestionWidget({super.key, required this.captureType, required this.question, this.onDone});

  @override
  State<CaptureQuestionWidget> createState() => _CaptureQuestionWidgetState();
}

class _CaptureQuestionWidgetState extends State<CaptureQuestionWidget> {
  String? captureAnswer;

  @override
  Widget build(BuildContext context) {
    Future<void> captureData() async {
      final newPathAnswer = await Navigator.push(context, MaterialPageRoute(
        builder: (context) {
          switch (widget.captureType) {
            case CaptureType.image:
              return CapturePictureScreen(
                studyId: context.read<AppState>().activeSubject!.studyId,
                userId: context.read<AppState>().activeSubject!.userId,
              );
            case CaptureType.audio:
              return RecordAudioScreen(
                studyId: context.read<AppState>().activeSubject!.studyId,
                userId: context.read<AppState>().activeSubject!.userId,
              );
          }
        },
      ));
      if (newPathAnswer != null) {
        setState(() {
          captureAnswer = newPathAnswer;
        });
        widget.onDone!(widget.question.constructAnswer(newPathAnswer));
      }
    }

    return Column(
      children: [
        captureAnswer == null
            ? TextButton.icon(
                label: Text(widget.captureType == CaptureType.image ? AppLocalizations.of(context)!.take_a_photo : AppLocalizations.of(context)!.start_recording),
                icon: Icon(widget.captureType == CaptureType.image ? MdiIcons.camera : Icons.mic),
                onPressed: () {
                  if (kIsWeb) {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      content: Text(AppLocalizations.of(context)!.multimodal_not_supported),
                    ));
                  } else {
                    captureData();
                  }
                },
              )
            : Row(
                children: <Widget>[
                  Icon(
                    MdiIcons.checkCircleOutline,
                  ),
                  const SizedBox(width: 10.0),
                  Text(AppLocalizations.of(context)!.data_captured),
                ],
              ),
      ],
    );
  }
}
