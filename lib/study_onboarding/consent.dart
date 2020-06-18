import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../util/localization.dart';

class ConsentScreen extends StatefulWidget {
  @override
  _ConsentScreenState createState() => _ConsentScreenState();
}

class _ConsentScreenState extends State<ConsentScreen> {
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
                Text(
                  Nof1Localizations.of(context).translate('please_give_consent'),
                  style: theme.textTheme.headline5,
                ),
                SizedBox(height: 40),
                RaisedButton(
                  onPressed: () => Navigator.pop(context, false),
                  child: Text(Nof1Localizations.of(context).translate('cancel')),
                ),
                RaisedButton(
                  onPressed: () => Navigator.pop(context, true),
                  child: Text(Nof1Localizations.of(context).translate('accept')),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
