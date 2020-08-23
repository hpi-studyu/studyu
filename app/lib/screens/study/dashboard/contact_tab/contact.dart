import 'package:flutter/material.dart';

import '../../../../util/localization.dart';
import '../../../app_onboarding/about.dart';
import 'contact_us.dart';
import 'faq.dart';

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
            const SizedBox(height: 30),
            SizedBox(
              width: 160,
              height: 60,
              child: RaisedButton(
                  color: Colors.lightBlue[200],
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => FAQ()),
                    );
                  },
                  child: Text('FAQ', style: TextStyle(fontSize: 18)),
                  textColor: Colors.white),
            ),
            const SizedBox(height: 30),
            SizedBox(
              width: 160,
              height: 60,
              child: RaisedButton(
                  color: Colors.blue[400],
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => ContactUs()),
                    );
                  },
                  child: Text(Nof1Localizations.of(context).translate('contact'), style: TextStyle(fontSize: 18)),
                  textColor: Colors.white),
            ),
            const SizedBox(height: 30),
            SizedBox(
              width: 160,
              height: 60,
              child: RaisedButton(
                  color: Colors.blue[600],
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => AboutScreen()),
                    );
                  },
                  child: Text(Nof1Localizations.of(context).translate('about'), style: TextStyle(fontSize: 18)),
                  textColor: Colors.white),
            ),
          ],
        ),
      ),
    );
  }
}
