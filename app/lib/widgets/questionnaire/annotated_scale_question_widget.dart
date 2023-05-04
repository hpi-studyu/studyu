import 'package:flutter/material.dart';
import 'package:studyu_core/core.dart';

import 'custom_slider.dart';
import 'question_widget.dart';

class AnnotatedScaleQuestionWidget extends QuestionWidget {
  final AnnotatedScaleQuestion question;
  final Function(Answer) onDone;

  const AnnotatedScaleQuestionWidget({Key key, @required this.question, this.onDone}) : super(key: key);

  @override
  State<AnnotatedScaleQuestionWidget> createState() => _AnnotatedScaleQuestionWidgetState();
}

class _AnnotatedScaleQuestionWidgetState extends State<AnnotatedScaleQuestionWidget> {
  double value;

  // double actualValue;
  bool sliderTouched;

  @override
  void initState() {
    super.initState();
    value = widget.question.initial;
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
            value = val;
            widget.onDone(widget.question.constructAnswer(value));
          }),
          activeColor: Theme.of(context).primaryColor,
          linearStep: false,
          steps: widget.question,
        ),
      ],
    );
  }
}
