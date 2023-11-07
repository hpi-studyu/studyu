import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:studyu_core/core.dart';

import 'custom_slider.dart';
import 'question_widget.dart';

class AnnotatedScaleQuestionWidget extends QuestionWidget {
  final AnnotatedScaleQuestion question;
  final Function(Answer)? onDone;

  const AnnotatedScaleQuestionWidget({super.key, required this.question, this.onDone});

  @override
  State<AnnotatedScaleQuestionWidget> createState() => _AnnotatedScaleQuestionWidgetState();
}

class _AnnotatedScaleQuestionWidgetState extends State<AnnotatedScaleQuestionWidget> {
  double? value;
  late bool sliderTouched;

  @override
  void initState() {
    super.initState();
    value = widget.question.initial;
    sliderTouched = false;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CustomSlider(
          minValue: widget.question.minimum,
          maxValue: widget.question.maximum,
          value: value,
          minorTick: 0,
          labelValuePrecision: 0,
          tickValuePrecision: 0,
          onChanged: (val) => setState(() {
            value = val;
            // actualValue = annotations[(val / widget.question.maximum+1 * (annotations.length)).ceil().toInt()];
            // print('Slider value (linear): $value');
            // print('Actual value (non-linear): $actualValue');
            //widget.onDone(widget.question.constructAnswer(value));
          }),
          onChangeEnd: (val) => setState(() {
            sliderTouched = true;
            value = val;
            widget.onDone!(widget.question.constructAnswer(value!));
          }),
          activeColor: Theme.of(context).primaryColor,
          linearStep: false,
          steps: widget.question,
        ),
        if (!sliderTouched)
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: () {
                setState(() {
                  sliderTouched = true;
                });
                widget.onDone!(widget.question.constructAnswer(value!));
              },
              child: Text(AppLocalizations.of(context)!.done),
            ),
          )
      ],
    );
  }
}
