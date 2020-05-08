import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class AccountManagement extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: <Widget>[
          Text("Peter"),
          SizedBox(height: 20,),
          Text("Müller"),
          SizedBox(height: 20,),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.max,
            children: <Widget>[
              Icon(Icons.camera_alt),
              Icon(Icons.face),
            ],
          ),
        ],
      ),
    );
  }
}