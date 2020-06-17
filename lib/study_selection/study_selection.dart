import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:provider/provider.dart';

import '../database/daos/study_dao.dart';
import '../database/models/models.dart';
import '../questionnaire_widgets/questionnaire_widget.dart';
import '../routes.dart';
import '../study_onboarding/onboarding_model.dart';
import '../util/localization.dart';

class StudySelectionScreen extends StatelessWidget {
  Future<void> navigateToEligibilityCheck(BuildContext context, Study selectedStudy) async {
    final study = await StudyDao().getStudyWithStudyDetails(selectedStudy);
    final result = await Navigator.push(
        context,
        QuestionnaireScreen.routeFor(study.studyDetails.questionnaire.questions,
            title: 'Check eligibility', criteria: study.studyDetails.eligibility));
    if (result.conditionResult != null && result.conditionResult) {
      print('Patient is eligible');
      context.read<OnboardingModel>().selectedStudy = study;
      Navigator.pushNamed(context, Routes.interventionSelection);
    } else if (result.answers != null) {
      final reason =
          study.studyDetails.eligibility.firstWhere((criterion) => criterion.isViolated(result.answers)).reason;
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
      appBar: AppBar(
        title: Text(Nof1Localizations.of(context).translate('study_selection')),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(20),
              child: Text(
                Nof1Localizations.of(context).translate('study_selection_description'),
                style: theme.textTheme.headline5,
              ),
            ),
            FutureBuilder(
              future: StudyDao().getAllStudies(),
              builder: (_context, snapshot) {
                return snapshot.hasData
                    ? ListView.builder(
                        shrinkWrap: true,
                        physics: NeverScrollableScrollPhysics(),
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
          ],
        ),
      ),
    );
  }
}
