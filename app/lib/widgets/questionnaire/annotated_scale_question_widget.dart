import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:studyou_core/models/models.dart';
import 'package:studyou_core/util/localization.dart';

import 'question_widget.dart';

class AnnotatedScaleQuestionWidget extends QuestionWidget {
  final AnnotatedScaleQuestion question;
  final Function(Answer) onDone;

  AnnotatedScaleQuestionWidget({@required this.question, this.onDone});

  @override
  State<AnnotatedScaleQuestionWidget> createState() => _AnnotatedScaleQuestionWidgetState();
}

class _AnnotatedScaleQuestionWidgetState extends State<AnnotatedScaleQuestionWidget> {
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

  Widget _constructAnnotationWidgetFor(Annotation annotation, BuildContext context) {
    return Text(annotation.annotation, style: Theme.of(context).textTheme.headline6);
  }

  List<Widget> _generateAnnotations(BuildContext context) {
    var annotations = [...widget.question.annotations];
    if (annotations.isEmpty) return [];

    // Ensure annotation order is correct for widget generation
    annotations.sort((a, b) => a.value.compareTo(b.value));
    if (widget.question.maximum < widget.question.minimum) annotations = annotations.reversed.toList();

    final items = <Widget>[_constructAnnotationWidgetFor(annotations.first, context)];
    for (var i = 0; i < annotations.length - 1; ++i) {
      final distanceBetweenAnnotations = (annotations[i].value - annotations[i + 1].value).abs();
      items.addAll([
        Spacer(flex: distanceBetweenAnnotations),
        _constructAnnotationWidgetFor(annotations[i + 1], context),
      ]);
    }

    return items;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            SizedBox(width: 16),
            ..._generateAnnotations(context),
            SizedBox(width: 16),
          ],
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
          child: Text(Nof1Localizations.of(context).translate('done')),
        )
      ],
    );
  }
}
