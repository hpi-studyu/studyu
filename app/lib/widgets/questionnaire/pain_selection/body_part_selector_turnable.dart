// This code is taken from the package by Tim Lehmann (timcreatedit)
// Source: https://github.com/timcreatedit/body_part_selector
// Licensed under the MIT License.

import 'package:flutter/material.dart';
import 'package:studyu_app/spacing.dart';
import 'package:studyu_app/widgets/questionnaire/pain_selection/body_part_selector.dart';
import 'package:studyu_core/core.dart';

/// A widget that displays front and back views of a body for selection.
/// This widget provides a [SegmentedButton] to switch between [BodySide.front]
/// and [BodySide.back] views, wrapping the [BodyPartSelector].
class BodyPartSelectorTurnable extends StatefulWidget {
  const BodyPartSelectorTurnable({
    required this.body,
    super.key,
    this.onPainChanged,
    this.scale = PainScale.english,
    this.unselectedColor,
    this.unselectedOutlineColor,
    this.padding = const EdgeInsets.all(StudyUSpacing.space4),
    this.frontButtonText = 'Front',
    this.backButtonText = 'Back',
    this.frontButtonIcon = const Icon(Icons.face),
    this.backButtonIcon = const Icon(Icons.face_retouching_natural),
  });

  /// The body object containing the full hierarchy of parts and their pain state.
  final Body body;

  /// Called when pain details for a body part are updated via the dialog.
  final void Function(
    String parentPartId,
    String childPartId,
    BodyPain newPain,
  )?
  onPainChanged;

  /// The configuration for the pain scale, including styles and translations.
  final PainScale scale;

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
          padding: const EdgeInsets.symmetric(vertical: StudyUSpacing.space2),
          child: SegmentedButton<BodySide>(
            showSelectedIcon: false,
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
        const SizedBox(height: StudyUSpacing.space4),
        Padding(
          padding: widget.padding,
          child: BodyPartSelector(
            side: _side,
            body: widget.body,
            onPainChanged: widget.onPainChanged,
            scale: widget.scale,
            unselectedColor: widget.unselectedColor,
            unselectedOutlineColor: widget.unselectedOutlineColor,
          ),
        ),
      ],
    );
  }
}
