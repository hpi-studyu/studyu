import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class StudyDesignerCard extends StatelessWidget {
  final Widget child;
  final bool isEditing;
  final void Function() remove;
  final void Function() select;

  const StudyDesignerCard(
      {@required this.child, @required this.isEditing, @required this.select, @required this.remove, Key key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        onTap: select,
        child: Card(
            margin: EdgeInsets.all(10.0),
            child: Column(children: [
              if (isEditing)
                ButtonBar(
                  children: <Widget>[
                    FlatButton(
                      onPressed: remove,
                      child: const Text('Delete'),
                    ),
                  ],
                ),
              child
            ])));
  }
}
