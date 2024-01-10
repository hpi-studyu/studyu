import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:studyu_core/core.dart';

import 'question_widget.dart';

@Deprecated('Use [AnnotatedScaleQuestionWidget]')
class VisualAnalogueQuestionWidget extends QuestionWidget {
  final VisualAnalogueQuestion question;
  final Function(Answer)? onDone;

  const VisualAnalogueQuestionWidget({super.key, required this.question, this.onDone});

  @override
  State<VisualAnalogueQuestionWidget> createState() => _VisualAnalogueQuestionWidgetState();
}

@Deprecated('Use [_AnnotatedScaleQuestionWidgetState]')
class _VisualAnalogueQuestionWidgetState extends State<VisualAnalogueQuestionWidget> {
  late double value;

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
        Column(
          children: [
            Row(
              children: [
                Expanded(child: Text(widget.question.minimumAnnotation)),
                FittedBox(child: Text(widget.question.maximumAnnotation)),
              ],
            ),
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(widget.question.minimumColor), Color(widget.question.maximumColor)],
                ),
              ),
              constraints: const BoxConstraints.expand(height: 4),
            ),
          ],
        ),
        Slider(
          value: value,
          onChanged: changed,
          min: widget.question.minimum,
          max: widget.question.maximum,
          divisions: (widget.question.maximum - widget.question.minimum) ~/ widget.question.step,
        ),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton(
            onPressed: () => widget.onDone!(widget.question.constructAnswer(value)),
            child: Text(AppLocalizations.of(context)!.done),
          ),
        )
      ],
    );
  }
}
