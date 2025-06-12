import 'package:flutter/material.dart';
import 'package:studyu_app/l10n/app_localizations.dart';
import 'package:studyu_app/widgets/questionnaire/pain_selection/body_part_selector.dart';
import 'package:studyu_app/widgets/questionnaire/pain_selection/body_part_selector_turnable.dart';
import 'package:studyu_app/widgets/questionnaire/questions/question_widget.dart';
import 'package:studyu_app/widgets/selectable_button.dart';
import 'package:studyu_core/core.dart';

/// A custom German configuration for the pain scale.
/// This can be adapted or replaced with a default or localized version.

class PainQuestionWidget extends QuestionWidget {
  final PainQuestion question;
  final Function(Answer)? onDone;

  const PainQuestionWidget({super.key, required this.question, this.onDone});

  @override
  State<PainQuestionWidget> createState() => _PainQuestionWidgetState();
}

class _PainQuestionWidgetState extends State<PainQuestionWidget> {
  // The state is now a BodyParts object, which holds the pain level for each part.
  BodyParts _bodyParts = const BodyParts();

  @override
  void initState() {
    super.initState();
    // Here you could potentially load an initial state from a previous answer
    // For example: if (widget.question.answer != null) { ... }
  }

  /// This callback is triggered when a user selects or updates a pain level
  /// on the body part selector.
  void _onPainChanged(String partId, int painLevel) {
    setState(() {
      _bodyParts = _bodyParts.withPainLevel(partId, painLevel);
    });
  }

  void _onDone() {
    widget.onDone!(widget.question.constructAnswer(_bodyParts));
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // The main interactive widget for selecting body parts and pain levels.
        BodyPartSelectorTurnable(
          bodyParts: _bodyParts,
          onPainChanged: _onPainChanged,
          scale: germanPainScale,
          frontButtonIcon: const Icon(Icons.face_outlined),
          backButtonIcon: const Icon(Icons.accessibility_new_outlined),
        ),
        const SizedBox(height: 16),
        SelectableButton(
          onTap: _onDone,
          child: Text("Done"),
        ),
      ],
    );
  }
}

WongBakerScale generateLocalizedScale(BuildContext context) {
  final loc = AppLocalizations.of(context)!;

  return WongBakerScale(
    painIndicatorText: loc.painIndicatorText,
    dialogTitle: loc.dialogTitle,
    okButton: loc.okButton,
    cancelButton: loc.cancelButton,
    levels: {
      0: PainLevelStyle(
        face: '😄',
        description: loc.painLevel_0,
        color: Color(0xFF4CAF50),
      ),
      2: PainLevelStyle(
        face: '😊',
        description: loc.painLevel_2,
        color: Color(0xFF8BC34A),
      ),
      4: PainLevelStyle(
        face: '😐',
        description: loc.painLevel_4,
        color: Color(0xFFFFEB3B),
        textColor: Colors.black87,
      ),
      6: PainLevelStyle(
        face: '😕',
        description: loc.painLevel_6,
        color: Color(0xFFFF9800),
      ),
      8: PainLevelStyle(
        face: '😢',
        description: loc.painLevel_8,
        color: Color(0xFFF44336),
      ),
      10: PainLevelStyle(
        face: '😭',
        description: loc.painLevel_10,
        color: Color(0xFFB71C1C),
      ),
    },
  );
}
