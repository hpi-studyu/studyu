import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../database/models/interventions/intervention.dart';
import '../database/models/models.dart';
import '../routes.dart';
import '../study_onboarding/app_state.dart';
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
                onPressed: () => Navigator.pushNamed(context, Routes.about),
                child: Text(Nof1Localizations.of(context).translate('what_is_nof1')),
              ),
              SizedBox(height: 20),
              RaisedButton(
                onPressed: () => Navigator.pushReplacementNamed(context, Routes.terms),
                child: Text(Nof1Localizations.of(context).translate('get_started')),
              ),
            ],
          ),
        ),
      ),
      // Only display button in debug
      persistentFooterButtons: kReleaseMode
          ? null
          : [
              FlatButton(
                onPressed: () {
                  context.read<AppModel>()
                    ..selectedStudy = Study()
                    ..selectedInterventions = [Intervention('a', 'A'), Intervention('a', 'B')];
                  Navigator.pushNamed(context, Routes.dashboard);
                },
                child: Text('Skip to Dashboard'),
              ),
            ],
    );
  }
}
