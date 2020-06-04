import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../routes.dart';
import '../util/localization.dart';

class TermsScreen extends StatefulWidget {

  @override
  _TermsScreenState createState() => _TermsScreenState();
}

class _TermsScreenState extends State<TermsScreen> {

  bool _acceptedTerms = false;
  bool _acceptedPrivacy = false;
  bool _acceptedDisclaimer = false;

  bool userCanContinue() {
    return _acceptedTerms && _acceptedPrivacy && _acceptedDisclaimer;
  }

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
              Text('Terms', style: theme.textTheme.headline3),
              Text('take it or leave it'),
              CheckboxListTile(
                title: Text('I agree to the terms'),
                value: _acceptedTerms,
                onChanged: (val) {
                  setState(() {
                    _acceptedTerms = val;
                  });
                },
              ),
              SizedBox(height: 40),
              Text('Privacy', style: theme.textTheme.headline3),
              Text('big brother is watching you'),
              CheckboxListTile(
                title: Text('I read and understand the privacy statement'),
                value: _acceptedPrivacy,
                onChanged: (val) {
                  setState(() {
                    _acceptedPrivacy = val;
                  });
                },
              ),
              SizedBox(height: 40),
              Text('Disclaimer', style: theme.textTheme.headline3),
              Text('we are not liable'),
              CheckboxListTile(
                title: Text('I read and understand the disclaimer'),
                value: _acceptedDisclaimer,
                onChanged: (val) {
                  setState(() {
                    _acceptedDisclaimer = val;
                  });
                },
              ),
              SizedBox(height: 40),
              RaisedButton(
                onPressed: userCanContinue() ? () => Navigator.pushReplacementNamed(context, Routes.studySelection) : null,
                child: Text(Nof1Localizations.of(context).translate('get_started')),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
