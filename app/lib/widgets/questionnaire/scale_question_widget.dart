import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:studyu_app/widgets/questionnaire/annotated_scale_question_widget.dart';
import 'package:studyu_core/core.dart';

import 'question_widget.dart';

class ScaleQuestionWidget extends QuestionWidget {
  final ScaleQuestion question;
  final Function(Answer) onDone;

  ScaleQuestionWidget({@required this.question, this.onDone});

  @override
  State<ScaleQuestionWidget> createState() => _ScaleQuestionWidgetState();
}

class _ScaleQuestionWidgetState extends State<ScaleQuestionWidget> {
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
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            const SizedBox(width: 24),
            ...buildAnnotationWidgets(widget.question, context),
            const SizedBox(width: 24),
          ],
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 0, horizontal: 8),
          child: Slider(
            value: value,
            onChanged: changed,
            min: widget.question.minimum,
            max: widget.question.maximum,
            divisions: (widget.question.maximum - widget.question.minimum) ~/ widget.question.step,
          ),
        ),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton(
            onPressed: () => widget.onDone(widget.question.constructAnswer(value)),
            child: Text(AppLocalizations.of(context).done),
          ),
        )
      ],
    );
  }
}
