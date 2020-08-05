import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class StudyDesignerCard extends StatelessWidget {
  final int index;
  final Widget child;
  final bool isEditing;
  final void Function(int index) remove;
  final void Function(int index) onTap;

  const StudyDesignerCard(
      {@required this.index,
      @required this.child,
      @required this.isEditing,
      @required this.onTap,
      @required this.remove,
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
            child: Column(children: [
              if (isEditing)
                ButtonBar(
                  children: <Widget>[
                    FlatButton(
                      onPressed: () {
                        remove(index);
                      },
                      child: const Text('Delete'),
                    ),
                  ],
                ),
              child
            ])));
  }
}
