import 'package:StudYou/screens/app_onboarding/about.dart';
import 'package:StudYou/screens/study/dashboard/contact_tab/contact_us.dart';
import 'package:StudYou/screens/study/dashboard/contact_tab/faq.dart';
import 'package:flutter/material.dart';

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
                  child: Text('Contact Us', style: TextStyle(fontSize: 18)),
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
                  child: Text('About StudyU', style: TextStyle(fontSize: 18)),
                  textColor: Colors.white),
            )
          ],
        ),
      ),
    );
  }
}
