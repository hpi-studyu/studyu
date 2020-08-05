import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:studyou_core/models/models.dart';

class QuestionShowWidget extends StatelessWidget {
  final Question question;

  const QuestionShowWidget({@required this.question, Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListTile(title: Text(question.prompt.isEmpty ? '*Click to edit*' : question.prompt));
  }
}
