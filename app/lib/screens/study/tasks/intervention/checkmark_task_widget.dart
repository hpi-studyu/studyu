import 'package:flutter/material.dart';
import 'package:pimp_my_button/pimp_my_button.dart';

class CheckmarkTaskWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return PimpedButton(
        particle: DemoParticle(),
        pimpedWidgetBuilder: (context, controller) => RaisedButton.icon(
            onPressed: () async {
              await controller.forward(from: 0);
              await Future.delayed(Duration(milliseconds: 100));
              Navigator.pop(context);
            },
            icon: Icon(Icons.check, size: 32),
            label: Text('Complete', style: TextStyle(fontSize: 24))));
  }
}
