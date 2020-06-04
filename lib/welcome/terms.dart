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
      body: SingleChildScrollView(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ...buildSection(
                    theme,
                    'Terms',
                    'take it or leave it',
                    'I agree to the terms',
                        (val) =>  setState(() => _acceptedTerms = val ),
                    isChecked: _acceptedTerms
                ),
                ...buildSection(
                    theme,
                    'Privacy',
                    'big brother is watching you!',
                    'I read and understand the privacy statement',
                        (val) =>  setState(() => _acceptedPrivacy = val ),
                    isChecked: _acceptedPrivacy
                ),
                ...buildSection(
                    theme,
                    'Disclaimer',
                    'we are not liable',
                    'I read and understand the disclaimer',
                    (val) =>  setState(() => _acceptedDisclaimer = val ),
                    isChecked: _acceptedDisclaimer
                ),
                RaisedButton(
                  onPressed: userCanContinue() ? () => Navigator.pushReplacementNamed(context, Routes.studySelection) : null,
                  child: Text(Nof1Localizations.of(context).translate('get_started')),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  List<Widget> buildSection(ThemeData theme, String title, String descriptionText, String acknowledgmentText, Function onChange, {bool isChecked}) {
    return <Widget>[
      Text(title, style: theme.textTheme.headline3),
      Text(descriptionText),
      CheckboxListTile(
        title: Text(acknowledgmentText),
        value: isChecked,
        onChanged: onChange
      ),
      SizedBox(height: 40),
    ];
  }
}
