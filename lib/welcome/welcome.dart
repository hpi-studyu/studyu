import 'package:flutter/material.dart';

import '../util/localization.dart';

class WelcomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              Image(image: AssetImage('assets/fancy_logo.png')),
              SizedBox(height: 20),
              FlatButton(
                onPressed: () => Navigator.pushNamed(context, "/about"),
                color: Theme.of(context).primaryColor,
                textColor: Theme.of(context).secondaryHeaderColor,
                child: Text(Nof1Localizations.of(context).translate("what_is_nof1")),
              ),
              SizedBox(height: 20),
              FlatButton(
                onPressed: () => Navigator.pushReplacementNamed(context, "/studySelection"),
                color: Theme.of(context).primaryColor,
                textColor: Theme.of(context).secondaryHeaderColor,
                child: Text(Nof1Localizations.of(context).translate("get_started")),
              )
            ],
          ),
        ),
      ),
    );
  }
}
