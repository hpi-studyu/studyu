import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:studyou_core/models/models.dart';

import '../../../database/daos/study.dart';
import '../../../models/app_state.dart';
import '../../../routes.dart';
import '../../../util/localization.dart';
import 'eligibility_screen.dart';

class StudyOverviewScreen extends StatefulWidget {
  @override
  _StudyOverviewScreen createState() => _StudyOverviewScreen();
}

class _StudyOverviewScreen extends State<StudyOverviewScreen> {
  Study study;
  Future<Study> _futureStudyDetails;

  @override
  void initState() {
    super.initState();
    study = context.read<AppModel>().selectedStudy;
    _futureStudyDetails = loadStudyDetails(context);
  }

  Future<void> navigateToEligibilityCheck(BuildContext context, Study study) async {
    final result = await Navigator.push(
        context,
        EligibilityScreen.routeFor(study.studyDetails.questionnaire.questions,
            title: 'Check eligibility', criteria: study.studyDetails.eligibility));
    if (result == null) return;

    if (result.eligible != null && result.eligible) {
      print('Patient is eligible');
      Navigator.pushNamed(context, Routes.interventionSelection);
    } else if (result.answers != null) {
      Navigator.pop(context);
    }
  }

  Future<Study> loadStudyDetails(BuildContext context) async {
    final completeStudy = await StudyUtils.getStudyWithStudyDetails(study);
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
                future: _futureStudyDetails,
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
