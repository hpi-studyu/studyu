import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:studyou_core/models/models.dart';

class AnnotatedScaleQuestionEditorSection extends StatefulWidget {
  final AnnotatedScaleQuestion question;

  const AnnotatedScaleQuestionEditorSection({@required this.question, Key key}) : super(key: key);

  @override
  _AnnotatedScaleQuestionEditorSectionState createState() => _AnnotatedScaleQuestionEditorSectionState();
}

class _AnnotatedScaleQuestionEditorSectionState extends State<AnnotatedScaleQuestionEditorSection> {
  @override
  Widget build(BuildContext context) {
    return Column(children: [Text('Todo Annotated Scale')]);
  }
}
