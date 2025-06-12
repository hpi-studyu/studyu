import 'package:flutter/material.dart';
import 'package:studyu_app/l10n/app_localizations.dart';
import 'package:studyu_app/widgets/questionnaire/pain_selection/body_part_selector.dart';
import 'package:studyu_app/widgets/questionnaire/pain_selection/body_part_selector_turnable.dart';
import 'package:studyu_app/widgets/questionnaire/questions/question_widget.dart';
import 'package:studyu_core/core.dart';

class PainQuestionWidget extends QuestionWidget {
  final PainQuestion question;
  final Function(Answer)? onDone;

  const PainQuestionWidget({super.key, required this.question, this.onDone});

  @override
  State<PainQuestionWidget> createState() => _PainQuestionWidgetState();
}

class _PainQuestionWidgetState extends State<PainQuestionWidget> {
  BodyParts _bodyParts = const BodyParts();

  @override
  void initState() {
    super.initState();
  }

  /// This callback is triggered when a user selects or updates a pain level
  /// on the body part selector.
  void _onPainChanged(String partId, int painLevel) {
    setState(() {
      _bodyParts = _bodyParts.withPainLevel(partId, painLevel);
    });
  }

  void _onDone() {
    if (widget.onDone != null) {
      widget.onDone!(widget.question.constructAnswer(_bodyParts));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        BodyPartSelectorTurnable(
          bodyParts: _bodyParts,
          onPainChanged: _onPainChanged,
          scale: _generateLocalizedScale(context),
          frontButtonIcon: const Icon(Icons.face_outlined),
          backButtonIcon: const Icon(Icons.accessibility_new_outlined),
        ),
        const SizedBox(height: 16),
        OutlinedButton(
            onPressed: _onDone,
            child: Text(AppLocalizations.of(context)!.done)),
      ],
    );
  }
}

WongBakerScale _generateLocalizedScale(BuildContext context) {
  final loc = AppLocalizations.of(context);
  if (loc == null) {
    throw Exception("AppLocalizations not found in context");
  }

  return WongBakerScale(
    painIndicatorText: loc.painIndicatorText,
    dialogTitle: loc.dialogTitle,
    okButton: loc.okButton,
    cancelButton: loc.cancelButton,
    levels: {
      0: PainLevelStyle(
        face: '😄',
        description: loc.painLevel_0,
        color: const Color(0xFF4CAF50),
      ),
      2: PainLevelStyle(
        face: '😊',
        description: loc.painLevel_2,
        color: const Color(0xFF8BC34A),
      ),
      4: PainLevelStyle(
        face: '😐',
        description: loc.painLevel_4,
        color: const Color(0xFFFFEB3B),
        textColor: Colors.black87,
      ),
      6: PainLevelStyle(
        face: '😕',
        description: loc.painLevel_6,
        color: const Color(0xFFFF9800),
      ),
      8: PainLevelStyle(
        face: '😢',
        description: loc.painLevel_8,
        color: const Color(0xFFF44336),
      ),
      10: PainLevelStyle(
        face: '😭',
        description: loc.painLevel_10,
        color: const Color(0xFFB71C1C),
      ),
    },
  );
}
