import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:nof1_models/models/models.dart';

import 'question_widget.dart';

class VisualAnalogueQuestionWidget extends QuestionWidget {
  final VisualAnalogueQuestion question;
  final Function(Answer) onDone;

  VisualAnalogueQuestionWidget({@required this.question, this.onDone});

  @override
  State<VisualAnalogueQuestionWidget> createState() => _VisualAnalogueQuestionWidgetState();
}

class _VisualAnalogueQuestionWidgetState extends State<VisualAnalogueQuestionWidget> {
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
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 8),
          child: Column(children: [
            Row(
              children: [
                Expanded(child: Text(widget.question.minimumAnnotation)),
                FittedBox(child: Text(widget.question.maximumAnnotation)),
              ],
            ),
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                  colors: [widget.question.minimumColor, widget.question.maximumColor],
                ),
              ),
              constraints: BoxConstraints.expand(height: 4),
            ),
          ]),
        ),
        Slider(
          value: value,
          onChanged: changed,
          min: widget.question.minimum,
          max: widget.question.maximum,
          divisions: (widget.question.maximum - widget.question.minimum) ~/ widget.question.step,
        ),
        RaisedButton(
          onPressed: () => widget.onDone(widget.question.constructAnswer(value)),
          child: Text('done'),
        )
      ],
    );
  }
}
