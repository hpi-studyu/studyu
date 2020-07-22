import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:parse_server_sdk/parse_server_sdk.dart';
import 'package:provider/provider.dart';
import 'package:studyou_core/models/models.dart';
import 'package:studyou_core/queries/queries.dart';
import 'package:studyou_core/util/parse_future_builder.dart';

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
  Future<ParseResponse> _futureStudyDetails;

  @override
  void initState() {
    super.initState();
    study = context.read<AppModel>().selectedStudy;
    _futureStudyDetails = StudyQueries.getStudyDetails(study);
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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
        appBar: AppBar(
          title: Text(Nof1Localizations.of(context).translate('summary')),
        ),
        body: Center(
            child: ParseFetchOneFutureBuilder<Study>(
                queryFunction: () => _futureStudyDetails,
                builder: (_context, study) {
                  context.read<AppModel>().selectedStudy = study;
                  return SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            study.title,
                            style: theme.textTheme.headline5,
                          ),
                          Text(study.description),
                          SizedBox(height: 40),
                          RaisedButton(
                            onPressed: () {
                              navigateToEligibilityCheck(_context, study);
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
