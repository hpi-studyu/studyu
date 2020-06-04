import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../routes.dart';
import '../util/localization.dart';

class AboutScreen extends StatelessWidget {
  final String consensus =
      'An N-of-1 Study aims to identify the efficacy or side-effects of different interventions in an individual patient. It consists of a set of possible interventions (e.g. painkillers, exercise) and a set of observations (e.g. rate your pain). The duration of a study is divided into multiple cycles, which, in turn, are divided into blocks. During a block, a single intervention is performed according to a schedule (e.g. every morning). During the entire duration of the study, observations are recorded according to another schedule (e.g. once every evening, after a specific intervention).';

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Image(image: AssetImage('assets/images/icon.png'), height: 200),
              SizedBox(height: 40),
              Text('N-of-1 Studies', style: theme.textTheme.headline3),
              SizedBox(height: 40),
              Text(consensus),
              SizedBox(height: 40),
              RaisedButton(
                onPressed: () => Navigator.pushReplacementNamed(context, Routes.terms),
                child: Text(Nof1Localizations.of(context).translate('get_started')),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
