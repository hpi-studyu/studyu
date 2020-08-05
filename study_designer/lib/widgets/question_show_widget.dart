import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:studyou_core/models/models.dart';

class QuestionShowWidget extends StatelessWidget {
  final Question item;

  const QuestionShowWidget({@required this.item, Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListTile(title: Text(item.prompt.isEmpty ? '*Click to edit*' : item.prompt));
  }
}
