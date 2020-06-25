import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

import '../database/models/questionnaire/answer.dart';
import '../database/models/questionnaire/questions/visual_analogue_question.dart';
import 'question_widget.dart';

class VisualAnalogueQuestionWidget extends QuestionWidget {
  final VisualAnalogueQuestion question;
  final Function(Answer) onDone;

  VisualAnalogueQuestionWidget({@required this.question, this.onDone});

  @override
  State<VisualAnalogueQuestionWidget> createState() => _VisualAnalogueQuestionWidgetState();
}

class _VisualAnalogueQuestionWidgetState extends State<VisualAnalogueQuestionWidget> {
  int value;

  @override
  void initState() {
    super.initState();
    value = widget.question.minimum;
  }

  void changed(double value) {
    setState(() {
      this.value = value.toInt();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Slider(
          value: value.toDouble(),
          onChanged: changed,
          min: widget.question.minimum.toDouble(),
          max: widget.question.maximum.toDouble(),
          divisions: (widget.question.maximum - widget.question.minimum) ~/ widget.question.step,
        ),
        RaisedButton(
          onPressed: () => widget.onDone(widget.question.constructAnswer(value)),
        )
      ],
    );
  }
}
