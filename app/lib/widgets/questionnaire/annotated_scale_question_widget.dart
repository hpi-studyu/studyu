import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:studyu_core/core.dart';

import 'question_widget.dart';

class AnnotatedScaleQuestionWidget extends QuestionWidget {
  final AnnotatedScaleQuestion question;
  final Function(Answer) onDone;

  AnnotatedScaleQuestionWidget({@required this.question, this.onDone});

  @override
  State<AnnotatedScaleQuestionWidget> createState() =>
      _AnnotatedScaleQuestionWidgetState();
}

class _AnnotatedScaleQuestionWidgetState
    extends State<AnnotatedScaleQuestionWidget> {
  double value;

  @override
  void initState() {
    super.initState();
    value = widget.question.initial;
  }

  void changed(double value) {
    setState(() {
      this.value = value;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            const SizedBox(width: 16),
            ...buildAnnotationWidgets(widget.question, context),
            const SizedBox(width: 16),
          ],
        ),
        Slider(
          value: value,
          onChanged: changed,
          min: widget.question.minimum,
          max: widget.question.maximum,
          divisions: (widget.question.maximum - widget.question.minimum) ~/
              widget.question.step,
        ),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton(
            onPressed: () =>
                widget.onDone(widget.question.constructAnswer(value)),
            child: Text(AppLocalizations.of(context).done),
          ),
        )
      ],
    );
  }
}

List<Widget> buildAnnotationWidgets(
  AnnotatedScaleQuestion question,
  BuildContext context, {
  double labelMaxWidth = 80,
}) {
  List<Annotation> annotations = [...question.annotations];
  if (annotations.isEmpty) return [];

  // Ensure annotation order is correct for widget generation
  annotations.sort((a, b) => a.value.compareTo(b.value));
  if (question.maximum < question.minimum) {
    annotations = annotations.reversed.toList();
  }

  // Build & layout labels according to their annotation's value
  final List<Widget> labelWidgets = [];

  final textTheme = Theme.of(context).textTheme;
  final labelTextStyle =
      textTheme.caption.copyWith(fontSize: textTheme.button.fontSize);

  for (var i = 0; i < annotations.length; i++) {
    final Annotation current = annotations[i];
    final Annotation next =
        (i + 1 < annotations.length) ? annotations[i + 1] : null;

    if (current.annotation.isEmpty) {
      continue; // skip empty labels
    }

    final scaleRange = question.maximum - question.minimum;
    assert(scaleRange != 0);
    final flex = (next != null)
        ? ((next.value - current.value) / scaleRange * 100).toInt()
        : 0;
    final midValue = question.minimum + 0.5 * scaleRange;
    final midValueDistance =
        (current.value - midValue).abs() / (scaleRange / 2);
    final labelOffsetFactor = lerpDouble(-1.0, -0.5, midValueDistance);
    final labelOffset = labelOffsetFactor * labelMaxWidth / 2;

    Widget buildTextLabel(double offset) {
      return Container(
        width: labelMaxWidth,
        transform: Matrix4.translationValues(offset, 0, 0),
        child: Center(
          child: Text(
            current.annotation,
            style: labelTextStyle,
            softWrap: true,
            overflow: TextOverflow.visible,
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    Widget labelWidget;
    if (flex != 0) {
      // distribute space proportionally according to annotated values
      // and make sure labels stay centered on the value by offsetting them
      labelWidget = Expanded(
        flex: flex,
        child: Row(
          children: [
            buildTextLabel(labelOffset),
          ],
        ),
      );
    } else {
      // overlay the maximum label at the end
      labelWidget = Stack(
        clipBehavior: Clip.none,
        children: [
          Container(width: 1), // placeholder so we can use absolute positioning
          Positioned(
            left: -0.65 * labelMaxWidth,
            bottom: 0,
            child: buildTextLabel(0),
          ),
        ],
      );
    }

    labelWidgets.add(labelWidget);
  }

  return labelWidgets;
}
