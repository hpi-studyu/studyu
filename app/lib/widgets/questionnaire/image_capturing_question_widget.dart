import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:provider/provider.dart';
import 'package:studyu_app/models/app_state.dart';
import 'package:studyu_app/screens/study/multimodal/capture_picture_screen.dart';
import 'package:studyu_app/widgets/questionnaire/questions/question_widget.dart';
import 'package:studyu_core/core.dart';

class ImageCapturingQuestionWidget extends QuestionWidget {
  final ImageCapturingQuestion question;
  final Function(Answer)? onDone;

  const ImageCapturingQuestionWidget({super.key, required this.question, this.onDone});

  @override
  State<ImageCapturingQuestionWidget> createState() => _ImageCapturingQuestionWidgetState();
}

class _ImageCapturingQuestionWidgetState extends State<ImageCapturingQuestionWidget> {
  bool _hasCaptured = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    return Column(
      children: [
        !_hasCaptured
            ? TextButton.icon(
                label: Text(loc.take_a_photo),
                icon: Icon(MdiIcons.camera),
                onPressed: () async {
                  await _captureImage();
                },
              )
            : Row(
                children: <Widget>[
                  Icon(
                    MdiIcons.checkCircleOutline,
                  ),
                  const SizedBox(width: 10.0),
                  Text(loc.data_captured),
                ],
              ),
      ],
    );
  }

  Future<void> _captureImage() async {
    if (kIsWeb) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(AppLocalizations.of(context)!.multimodal_not_supported),
      ));
      return;
    }
    final appState = context.read<AppState>();
    final newPathAnswer = await Navigator.push(context, MaterialPageRoute(
      builder: (context) {
        return CapturePictureScreen(
          studyId: appState.activeSubject!.studyId,
          userId: appState.activeSubject!.userId,
        );
      },
    ));
    if (newPathAnswer != null) {
      setState(() {
        _hasCaptured = true;
      });
      widget.onDone!(widget.question.constructAnswer(newPathAnswer));
    }
  }
}
