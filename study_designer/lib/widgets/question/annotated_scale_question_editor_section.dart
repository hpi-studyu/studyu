import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:studyou_core/core.dart';

import './annotation_editor.dart';

class AnnotatedScaleQuestionEditorSection extends StatefulWidget {
  final AnnotatedScaleQuestion question;

  const AnnotatedScaleQuestionEditorSection({@required this.question, Key key}) : super(key: key);

  @override
  _AnnotatedScaleQuestionEditorSectionState createState() => _AnnotatedScaleQuestionEditorSectionState();
}

class _AnnotatedScaleQuestionEditorSectionState extends State<AnnotatedScaleQuestionEditorSection> {
  void _addAnnotation() {
    setState(() {
      final choice = Annotation();
      widget.question.annotations.add(choice);
    });
  }

  void _removeAnnotation(int index) {
    setState(() {
      widget.question.annotations.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      ListView.builder(
        shrinkWrap: true,
        itemCount: widget.question.annotations.length,
        itemBuilder: (buildContext, index) {
          return AnnotationEditor(
              key: UniqueKey(), annotation: widget.question.annotations[index], remove: () => _removeAnnotation(index));
        },
      ),
      Row(children: [
        Spacer(),
        ElevatedButton.icon(
            onPressed: _addAnnotation,
            icon: Icon(Icons.add),
            style: ElevatedButton.styleFrom(primary: Colors.green),
            label: Text(AppLocalizations.of(context).add_annotation)),
        Spacer()
      ])
    ]);
  }
}
