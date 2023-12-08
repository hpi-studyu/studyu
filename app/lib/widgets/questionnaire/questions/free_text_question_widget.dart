import 'package:flutter/material.dart';
import 'package:studyu_app/widgets/questionnaire/questions/question_widget.dart';
import 'package:studyu_core/core.dart';

class FreeTextQuestionWidget extends QuestionWidget {
  final FreeTextQuestion question;
  final Function(Answer)? onDone;

  const FreeTextQuestionWidget({super.key, required this.question, this.onDone});

  @override
  State<FreeTextQuestionWidget> createState() => _FreeTextQuestionWidgetState();
}

class _FreeTextQuestionWidgetState extends State<FreeTextQuestionWidget> {
  final textFieldController = TextEditingController();

  @override
  void initState() {
    super.initState();
    textFieldController.addListener(() {
      setState(() {
        widget.onDone!(widget.question.constructAnswer(textFieldController.text));
      });
    });
  }

  @override
  void dispose() {
    textFieldController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: textFieldController,
    );
  }
}
