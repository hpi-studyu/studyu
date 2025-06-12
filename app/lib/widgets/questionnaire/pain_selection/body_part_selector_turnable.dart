import 'package:flutter/material.dart';
import 'package:studyu_app/widgets/questionnaire/pain_selection/body_part_selector.dart';
import 'package:studyu_core/core.dart';

/// A widget that displays front and back views of a body for selection.
///
/// This widget provides a [SegmentedButton] to switch between [BodySide.front]
/// and [BodySide.back] views.
class BodyPartSelectorTurnable extends StatefulWidget {
  /// Creates a [BodyPartSelectorTurnable].
  const BodyPartSelectorTurnable({
    required this.bodyParts,
    super.key,
    this.onPainChanged,
    this.scale = WongBakerScale.english,
    this.unselectedColor,
    this.unselectedOutlineColor,
    this.padding = const EdgeInsets.all(16),
    this.frontButtonText = 'Front',
    this.backButtonText = 'Back',
    this.frontButtonIcon = const Icon(Icons.face),
    this.backButtonIcon = const Icon(Icons.face_retouching_natural),
  });

  /// The current selection of body parts with their pain levels.
  final BodyParts bodyParts;

  /// Called when a pain level for a body part is updated via the dialog.
  final void Function(String bodyPartId, int painLevel)? onPainChanged;

  /// The configuration for the pain scale, including styles and translations.
  final WongBakerScale scale;

  /// The color of body parts with no pain.
  final Color? unselectedColor;

  /// The color of the outline of body parts with no pain.
  final Color? unselectedOutlineColor;

  /// The padding around the rendered body.
  final EdgeInsets padding;

  /// The text for the front button.
  final String frontButtonText;

  /// The text for the back button.
  final String backButtonText;

  /// The icon for the front button. Can be null.
  final Widget? frontButtonIcon;

  /// The icon for the back button. Can be null.
  final Widget? backButtonIcon;

  @override
  State<BodyPartSelectorTurnable> createState() =>
      _BodyPartSelectorTurnableState();
}

class _BodyPartSelectorTurnableState extends State<BodyPartSelectorTurnable> {
  BodySide _side = BodySide.front;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: SegmentedButton<BodySide>(
            segments: [
              ButtonSegment(
                icon: widget.frontButtonIcon,
                value: BodySide.front,
                label: Text(widget.frontButtonText),
              ),
              ButtonSegment(
                icon: widget.backButtonIcon,
                value: BodySide.back,
                label: Text(widget.backButtonText),
              ),
            ],
            selected: {_side},
            onSelectionChanged: (newSelection) {
              setState(() {
                _side = newSelection.first;
              });
            },
          ),
        ),
        BodyPartSelector(
          side: _side,
          bodyParts: widget.bodyParts,
          onPainChanged: widget.onPainChanged,
          scale: widget.scale,
          unselectedColor: widget.unselectedColor,
          unselectedOutlineColor: widget.unselectedOutlineColor,
        ),
      ],
    );
  }
}
