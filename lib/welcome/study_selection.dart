//import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

import '../database/daos/study_dao.dart';
import '../database/models/models.dart';
import '../onboarding/intervention_selection.dart';
import '../questionnaire_widgets/questionnaire_widget.dart';

class StudySelectionScreen extends StatelessWidget {

  void navigateToEligibilityCheck(BuildContext context, Study selectedStudy) async {
    final isEligible = await Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => QuestionnaireWidget(
              questions: selectedStudy.eligibility,
              conditions: selectedStudy.conditions,
              title: 'Check eligibility',
            ))).then((value) => value[0]);
    if (isEligible != null && isEligible) {
      print('Patient is eligible');
      Navigator.pushReplacement(
          context,
          MaterialPageRoute(
              builder: (context) => InterventionSelection(
                    study: selectedStudy,
                  )));
    } else {
      Scaffold.of(context).showSnackBar(SnackBar(
        content: Text('You are not eligible for this study. Please select a different one.'),
        duration: Duration(seconds: 30),
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
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
                      return ListTile(
                          contentPadding: EdgeInsets.all(16),
                          onTap: () {
                            navigateToEligibilityCheck(context, currentStudy);
                          },
                          title: Center(
                              child: Text(currentStudy.title,
                                  style: theme.textTheme.headline6.copyWith(color: theme.primaryColor))),
                          subtitle: Center(child: Text(currentStudy.description)),
                          leading: Icon(MdiIcons.fromString(currentStudy.iconName ?? 'accountHeart'),
                              color: theme.primaryColor));
                    })
                : CircularProgressIndicator();
          },
        ),
      ),
    );
  }
}
