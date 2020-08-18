import 'package:flutter/material.dart';

import '../../../../theme.dart';
import '../../../../util/localization.dart';

class Contact extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(Nof1Localizations.of(context).translate('help')),
        centerTitle: true,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            RaisedButton(color: theme.primaryColor, onPressed: () {}, child: Text('FAQ')),
            RaisedButton(color: theme.primaryColor, onPressed: () {}, child: Text('Contact Support')),
            RaisedButton(color: theme.primaryColor, onPressed: () {}, child: Text('Imprint/About')),
          ],
        ),
      ),
    );
  }
}
