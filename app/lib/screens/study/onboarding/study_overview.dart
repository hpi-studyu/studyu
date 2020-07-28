import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:parse_server_sdk/parse_server_sdk.dart';
import 'package:provider/provider.dart';
import 'package:studyou_core/models/models.dart';
import 'package:studyou_core/queries/queries.dart';
import 'package:studyou_core/util/parse_future_builder.dart';

import '../../../models/app_state.dart';
import '../../../routes.dart';
import '../../../widgets/bottom_onboarding_navigation.dart';
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

  Future<void> navigateToEligibilityCheck(BuildContext context) async {
    final study = context.read<AppModel>().selectedStudy;
    final result = await Navigator.push(context, EligibilityScreen.routeFor(study: study));
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
        leading: Icon(MdiIcons.fromString(study.iconName)),
        title: Text(study.title),
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
                        SizedBox(height: 20),
                        Text(study.description),
                      ],
                    ),
                  ),
                );
              })),
      bottomNavigationBar: BottomOnboardingNavigation(
        onNext: () => navigateToEligibilityCheck(context),
      ),
    );
  }
}
