import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

import '../../routes.dart';

class WelcomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    print(Color(0xffff0000).value);
    print(Color(0xffffffff).value);
    print(Color(0xffff0b0b).value);
    print(Color(0xffff9b34).value);
    print(Color(0xff0444ff).value);
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Spacer(),
              Image(image: AssetImage('assets/images/icon_wide.png'), height: 200),
              SizedBox(height: 20),
              OutlinedButton.icon(
                icon: Icon(Icons.info),
                onPressed: () => Navigator.pushNamed(context, Routes.about),
                label: Text(AppLocalizations.of(context).what_is_studyu, style: TextStyle(fontSize: 20)),
              ),
              SizedBox(height: 20),
              OutlinedButton.icon(
                icon: Icon(MdiIcons.accountBox),
                onPressed: () => Navigator.pushNamed(context, Routes.contact),
                label: Text(AppLocalizations.of(context).contact, style: TextStyle(fontSize: 20)),
              ),
              SizedBox(height: 20),
              OutlinedButton.icon(
                icon: Icon(MdiIcons.frequentlyAskedQuestions),
                onPressed: () => Navigator.pushNamed(context, Routes.faq),
                label: Text(AppLocalizations.of(context).faq, style: TextStyle(fontSize: 20)),
              ),
              Spacer(),
              OutlinedButton.icon(
                icon: Icon(MdiIcons.rocket, size: 30),
                onPressed: () => Navigator.pushNamed(context, Routes.terms),
                label: Text(AppLocalizations.of(context).get_started, style: TextStyle(fontSize: 20)),
              ),
              Spacer()
            ],
          ),
        ),
      ),
    );
  }
}
