import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../database/models/study.dart';
import '../questionnaire_widgets/questionnaire_widget.dart';
import '../routes.dart';
import '../study_onboarding/onboarding_model.dart';
import '../util/localization.dart';

class StudyOverviewScreen extends StatefulWidget {
  @override
  _StudyOverviewScreen createState() => _StudyOverviewScreen();
}

class _StudyOverviewScreen extends State<StudyOverviewScreen> {
  Study study;

  Future<void> navigateToEligibilityCheck(BuildContext context) async {
    final result = await Navigator.push(
        context,
        QuestionnaireScreen.routeFor(study.studyDetails.questionnaire.questions,
            title: 'Check eligibility', criteria: study.studyDetails.eligibility));
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

  @override
  void initState() {
    super.initState();
    study = context.read<OnboardingModel>().selectedStudy;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
        appBar: AppBar(
          title: Text(Nof1Localizations.of(context).translate('summary')),
        ),
        body: Builder(builder: (_context) {
          return Center(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'todo put summary here',
                      style: theme.textTheme.headline5,
                    ),
                    SizedBox(height: 40),
                    RaisedButton(
                      onPressed: () {
                        navigateToEligibilityCheck(_context);
                      },
                      child: Text(Nof1Localizations.of(context).translate('get_started')),
                    ),
                  ],
                ),
              ),
            ),
          );
        }));
  }
}
