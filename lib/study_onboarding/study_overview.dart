import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:nof1_models/models/models.dart';
import 'package:provider/provider.dart';

import '../database/daos/study_dao.dart';
import '../routes.dart';
import '../study_onboarding/app_state.dart';
import '../util/localization.dart';
import 'eligibility_screen.dart';

class StudyOverviewScreen extends StatefulWidget {
  @override
  _StudyOverviewScreen createState() => _StudyOverviewScreen();
}

class _StudyOverviewScreen extends State<StudyOverviewScreen> {
  Study study;

  @override
  void initState() {
    super.initState();
    study = context.read<AppModel>().selectedStudy;
  }

  Future<void> navigateToEligibilityCheck(BuildContext context, Study study) async {
    final result = await Navigator.push(
        context,
        EligibilityScreen.routeFor(study.studyDetails.questionnaire.questions,
            title: 'Check eligibility', criteria: study.studyDetails.eligibility));
    if (result == null) return;

    if (result.conditionResult != null && result.conditionResult) {
      print('Patient is eligible');
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

  Future<Study> loadStudyDetails(BuildContext context) async {
    final completeStudy = await StudyDao().getStudyWithStudyDetails(study);
    context.read<AppModel>().selectedStudy = completeStudy;
    return completeStudy;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
        appBar: AppBar(
          title: Text(Nof1Localizations.of(context).translate('summary')),
        ),
        body: Center(
            child: FutureBuilder(
                future: loadStudyDetails(context),
                builder: (_context, snapshot) {
                  return !snapshot.hasData
                      ? CircularProgressIndicator()
                      : SingleChildScrollView(
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  snapshot.data.title,
                                  style: theme.textTheme.headline5,
                                ),
                                Text(snapshot.data.description),
                                SizedBox(height: 40),
                                RaisedButton(
                                  onPressed: () {
                                    navigateToEligibilityCheck(_context, snapshot.data);
                                  },
                                  child: Text(Nof1Localizations.of(context).translate('get_started')),
                                ),
                              ],
                            ),
                          ),
                        );
                })));
  }
}
