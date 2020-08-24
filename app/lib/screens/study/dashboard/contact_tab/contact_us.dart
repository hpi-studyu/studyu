import 'package:StudYou/util/localization.dart';
import 'package:flutter/material.dart';

class ContactUs extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Container(
              alignment: Alignment.topCenter,
              child: Image(
                image: AssetImage('assets/images/icon_wide.png'),
                width: double.infinity,
                //height: 200,
                //fit: BoxFit.cover,
              ),
            ),
            Icon(Icons.pin_drop, size: 50, color: Colors.cyan[300]),
            SizedBox(height: 10),
            SelectableText(
              'Prof.-Dr.-Helmert-Straße 2-3, \n 14482 Potsdam',
              style: TextStyle(color: Colors.blueAccent),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 20),
            Icon(Icons.settings_cell, size: 45, color: Colors.cyan[300]),
            SizedBox(height: 10),
            SelectableText(
              '+ 49- (0) 331 5509-0',
              style: TextStyle(color: Colors.blueAccent),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 20),
            Icon(Icons.mail, size: 40, color: Colors.cyan[300]),
            SizedBox(height: 10),
            SelectableText(
              ' hpi-info (at) hpi.de',
              style: TextStyle(color: Colors.blueAccent),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
      appBar: AppBar(
        title: Text(Nof1Localizations.of(context).translate('Contact Us')),
      ),
    );
  }
}
