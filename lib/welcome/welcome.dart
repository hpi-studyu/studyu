import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../util/localization.dart';

class WelcomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Image(image: AssetImage('assets/images/icon.png'), height: 200),
              SizedBox(height: 20),
              RaisedButton(
                onPressed: () => Navigator.pushNamed(context, "/about"),
                child: Text(Nof1Localizations.of(context).translate("what_is_nof1")),
              ),
              SizedBox(height: 20),
              RaisedButton(
                onPressed: () => Navigator.pushReplacementNamed(context, "/studySelection"),
                child: Text(Nof1Localizations.of(context).translate("get_started")),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
