import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../routes.dart';
import '../util/localization.dart';

class AboutScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(Nof1Localizations.of(context).translate('what_is_nof1')),
      ),
      body: PageView(
        children: <Widget>[
          Container(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Image(image: AssetImage('assets/images/icon.png'), height: 100),
                    SizedBox(height: 40),
                    Text('N-of-1', style: theme.textTheme.headline3),
                    SizedBox(height: 40),
                    Text(Nof1Localizations.of(context).translate('description_part1')),
                    SizedBox(height: 40),
                  ]),
            ),
          ),
          Container(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Image(image: AssetImage('assets/images/icon.png'), height: 100),
                    SizedBox(height: 40),
                    Text(Nof1Localizations.of(context).translate('description_part2')),
                  ]),
            ),
          ),
          Container(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Image(image: AssetImage('assets/images/icon.png'), height: 100),
                    SizedBox(height: 40),
                    Text(Nof1Localizations.of(context).translate('description_part3')),
                    SizedBox(height: 40),
                    RaisedButton(
                      onPressed: () => Navigator.pushReplacementNamed(context, Routes.terms),
                      child: Text(Nof1Localizations.of(context).translate('get_started')),
                    ),
                  ]),
            ),
          ),
        ],
      ),
    );
  }
}
