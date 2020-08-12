import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:studyou_core/models/models.dart';

class VisualAnalogueQuestionEditorSection extends StatefulWidget {
  final VisualAnalogueQuestion question;

  const VisualAnalogueQuestionEditorSection({@required this.question, Key key}) : super(key: key);

  @override
  _VisualAnalogueQuestionEditorSectionState createState() => _VisualAnalogueQuestionEditorSectionState();
}

class _VisualAnalogueQuestionEditorSectionState extends State<VisualAnalogueQuestionEditorSection> {
  @override
  Widget build(BuildContext context) {
    return Column(children: [Text('Todo Visual Analogue')]);
  }
}
