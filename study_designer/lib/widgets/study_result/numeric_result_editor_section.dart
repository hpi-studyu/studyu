import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:studyou_core/models/study_results/results/numeric_result.dart';

class NumericResultEditorSection extends StatefulWidget {
  final NumericResult result;

  const NumericResultEditorSection({@required this.result, Key key}) : super(key: key);

  @override
  _NumericResultEditorSectionState createState() => _NumericResultEditorSectionState();
}

class _NumericResultEditorSectionState extends State<NumericResultEditorSection> {
  @override
  Widget build(BuildContext context) {
    return Column(children: []);
  }
}
