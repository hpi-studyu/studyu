import 'package:flutter/material.dart';

import '../../../../util/localization.dart';

class Contact extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(Nof1Localizations.of(context).translate('contact')),
        centerTitle: true,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            RaisedButton(color: Colors.amber, onPressed: () {}, child: Text('FAQ')),
            RaisedButton(color: Colors.cyan, onPressed: () {}, child: Text('Contact Support')),
            RaisedButton(color: Colors.amber, onPressed: () {}, child: Text('Imprint/About')),
          ],
        ),
      ),
    );
  }
}
