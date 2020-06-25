import 'package:flutter/material.dart';

class CheckmarkTaskWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return RaisedButton.icon(
        onPressed: () {
          Navigator.pop(context);
        },
        icon: Icon(Icons.check),
        label: Text('Complete', style: TextStyle(fontSize: 24)));
    ;
  }
}
