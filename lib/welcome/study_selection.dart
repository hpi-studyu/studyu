import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

import '../database/daos/study_dao.dart';
import '../database/models/models.dart';
import '../onboarding/eligibility_check.dart';

class StudySelectionScreen extends StatelessWidget {
  /*final _availableStudies = [
    Study('1', 'tea_vs_coffee', ''),
    Study('', 'weed_vs_alcohol', ''),
    Study('', 'back_pain', '')
  ];*/

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
        child: FutureBuilder(
          future: StudyDao().getAllStudies(),
          builder: (_context, snapshot) {
            return snapshot.hasData
                ? ListView.builder(
                    shrinkWrap: true,
                    itemCount: snapshot.data.length,
                    itemBuilder: (context, index) {
                      final Study currentStudy = snapshot.data[index];
                      return Center(
                        child: ListTile(
                          onTap: () {
                            print(currentStudy);
                            navigateToEligibilityCheck(context, currentStudy);
                          },
                          title: Center(child: Text(currentStudy.title)),
                          subtitle: Center(child: Text(currentStudy.description),),
                          leading: currentStudy.id == '2' ? Icon(MdiIcons.cannabis) : Icon(MdiIcons.accountHeart),
                          trailing: currentStudy.id == '2' ? Icon(MdiIcons.glassMugVariant) : Icon(MdiIcons.pill),
                        ),
                      );
                    })
                : CircularProgressIndicator();
          },
        ),
      ),
    );
  }
}
