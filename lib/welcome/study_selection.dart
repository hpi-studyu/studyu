import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../onboarding/eligibility_check.dart';
import '../util/localization.dart';

class StudySelectionScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            RaisedButton(
              onPressed: () => print("Tea vs. Coffee"),
              child: Text(Nof1Localizations.of(context).translate("tea_vs_coffee")),
            ),
            SizedBox(height: 20),
            RaisedButton(
              onPressed: () => print("Weed vs. Alcohol"),
              child: Text(Nof1Localizations.of(context).translate("weed_vs_alcohol")),
            ),
            SizedBox(height: 20),
            RaisedButton(
              onPressed: () {
                kIsWeb
                    ? Navigator.push(context, MaterialPageRoute(builder: (_context) {
                        return Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: <Widget>[
                              Text(
                                "Web doesn't support DB yet.",
                                style: Theme.of(context).textTheme.headline3,
                              ),
                              SizedBox(
                                height: 20,
                              ),
                              RaisedButton(
                                onPressed: () => Navigator.pushReplacementNamed(context, "/dashboard"),
                                child: Text("Continue"),
                              )
                            ],
                          ),
                        );
                      }))
                    : Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => EligibilityCheckScreen(
                                  route: ModalRoute.of(context),
                                )));
              },
              child: Text(Nof1Localizations.of(context).translate("back_pain")),
            )
          ],
        ),
      ),
    );
  }
}
