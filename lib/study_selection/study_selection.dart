import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

import '../database/daos/study_dao.dart';
import '../database/models/models.dart';
import '../database/models/questionnaire/questionnaire_state.dart';
import '../questionnaire_widgets/questionnaire_widget.dart';
import '../routes.dart';
import '../study_onboarding/intervention_selection.dart';

class StudySelectionScreen extends StatelessWidget {
  void navigateToEligibilityCheck(BuildContext context, Study selectedStudy) async {
    final study = await StudyDao().getStudyWithStudyDetails(selectedStudy);
    final result = await Navigator.pushNamed(context, Routes.questionnaire,
        arguments: QuestionnaireScreenArguments(
          questions: study.studyDetails.questionnaire.questions,
          criteria: study.studyDetails.eligibility,
          title: 'Check eligibility',
        )) as List<Object>;
    if (result.isNotEmpty && result[0] != null && result[0]) {
      print('Patient is eligible');
      Navigator.pushNamed(context, Routes.interventionSelection,
          arguments: InterventionSelectionScreenArguments(study));
    } else if (result.length > 1 && result[1] != null) {
      final reason = study.studyDetails.eligibility
          .firstWhere((criterion) => criterion.isViolated((result[1] as QuestionnaireState)))
          .reason;
      Scaffold.of(context).showSnackBar(SnackBar(
        content: Text('You are not eligible for this study. $reason'),
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
