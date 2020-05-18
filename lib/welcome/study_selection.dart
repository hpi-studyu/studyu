import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

import '../models/models.dart';
import '../onboarding/eligibility_check.dart';
import '../util/localization.dart';

class StudySelectionScreen extends StatelessWidget {
  final _availableStudies = [Study('tea_vs_coffee'), Study('weed_vs_alcohol'), Study('back_pain')];

  void navigateToEligibilityCheck(BuildContext context, Study selectedStudy) {
    if (kIsWeb) {
      Navigator.push(context, MaterialPageRoute(builder: _buildWebCompatScreen));
    } else {
      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => EligibilityCheckScreen(
                    study: selectedStudy,
                    route: ModalRoute.of(context),
                  )));
    }
  }

  Widget _buildWebCompatScreen(BuildContext context) {
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
            onPressed: () => Navigator.pushReplacementNamed(context, '/dashboard'),
            child: Text('Continue'),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: ListView.builder(
            shrinkWrap: true,
            itemCount: _availableStudies.length,
            itemBuilder: (context, index) {
              return Center(
                child: ListTile(
                  onTap: () {
                    print(Nof1Localizations.of(context).translate(_availableStudies[index].id));
                    navigateToEligibilityCheck(context, _availableStudies[index]);
                  },
                  title: Center(child: Text(Nof1Localizations.of(context).translate(_availableStudies[index].id))),
                  leading: _availableStudies[index].id == 'weed_vs_alcohol'
                      ? Icon(MdiIcons.cannabis)
                      : Icon(MdiIcons.accountHeart),
                  trailing: _availableStudies[index].id == 'weed_vs_alcohol'
                      ? Icon(MdiIcons.glassMugVariant)
                      : Icon(MdiIcons.pill),
                ),
              );
            }),
      ),
    );
  }
}
