import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class AboutScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text("This could be your advertisement."),
            SizedBox(height: 20),
            FlatButton(
              onPressed: () => Navigator.pushReplacementNamed(context, "studySelection"),
              color: Theme.of(context).primaryColor,
              textColor: Theme.of(context).secondaryHeaderColor,
              child: Text("Get Started"),
            ),
          ],
        ),
      ),
    );
  }
}
