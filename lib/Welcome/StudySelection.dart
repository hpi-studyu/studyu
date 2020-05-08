import 'package:flutter/material.dart';

class StudySelectionScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            FlatButton(
              onPressed: () => print("Tea vs. Coffee"),
              color: Theme.of(context).primaryColor,
              textColor: Theme.of(context).secondaryHeaderColor,
              child: Text("Tea vs. Coffee"),
            ),
            SizedBox(height: 20,),
            FlatButton(
              onPressed: () => print("Weed vs. Alcohol"),
              color: Theme.of(context).primaryColor,
              textColor: Theme.of(context).secondaryHeaderColor,
              child: Text("Weed vs. Alcohol"),
            ),
            SizedBox(height: 20,),
            FlatButton(
              onPressed: () => Navigator.pushNamed(context, "dashboard"),
              color: Theme.of(context).primaryColor,
              textColor: Theme.of(context).secondaryHeaderColor,
              child: Text("Backpain"),
            )
          ],
        ),
      ),
    );
  }
}
