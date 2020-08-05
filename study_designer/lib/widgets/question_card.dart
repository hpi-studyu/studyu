import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:study_designer/widgets/question_edit_widget.dart';
import 'package:study_designer/widgets/question_show_widget.dart';
import 'package:studyou_core/models/models.dart';

class QuestionCard extends StatelessWidget {
  final int index;
  final Question item;
  final bool isEditing;
  final void Function(int index) remove;
  final void Function(int index) onTap;
  final void Function(bool validated) setValidated;

  const QuestionCard(
      {@required this.index,
      @required this.item,
      @required this.isEditing,
      @required this.onTap,
      @required this.remove,
      @required this.setValidated,
      Key key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        onTap(index);
      },
      child: Card(
          margin: EdgeInsets.all(10.0),
          child:
              isEditing ? QuestionEditWidget(item: item, remove: () => remove(index)) : QuestionShowWidget(item: item)),
    );
  }
}
