import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../routes.dart';
import '../util/localization.dart';

class ConsentScreen extends StatefulWidget {
  @override
  _ConsentScreenState createState() => _ConsentScreenState();
}

class _ConsentScreenState extends State<ConsentScreen> {
  bool _gaveConsent = true;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ...buildSection(theme,
                    title: 'Terms',
                    descriptionText: 'take it or leave it',
                    acknowledgmentText: 'I agree to the terms',
                    onChange: (val) => setState(() => _gaveConsent = val),
                    isChecked: _gaveConsent),
                RaisedButton(
                  onPressed: _gaveConsent ? () => Navigator.pushNamed(context, Routes.studySelection) : null,
                  child: Text(Nof1Localizations.of(context).translate('get_started')),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  List<Widget> buildSection(ThemeData theme,
      {String title, String descriptionText, String acknowledgmentText, Function onChange, bool isChecked}) {
    return <Widget>[
      Text(title, style: theme.textTheme.headline3),
      Text(descriptionText),
      CheckboxListTile(title: Text(acknowledgmentText), value: isChecked, onChanged: onChange),
      SizedBox(height: 40),
    ];
  }
}
