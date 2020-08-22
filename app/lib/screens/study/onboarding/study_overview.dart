import 'package:StudYou/widgets/study_tile.dart';
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
  ParseStudy study;
  Future<ParseResponse> _futureStudyDetails;

  @override
  void initState() {
    super.initState();
    study = context.read<AppState>().selectedStudy;
    _futureStudyDetails = StudyQueries.getStudyDetails(study);
  }

  Future<void> navigateToEligibilityCheck(BuildContext context) async {
    final study = context.read<AppState>().selectedStudy;
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
          child: SingleChildScrollView(
        child: Column(
          children: [
            Hero(
              tag: 'study_tile_${study.id}',
              child: Material(child: StudyTile(study: study)),
            ),
            ParseFetchOneFutureBuilder<ParseStudy>(
                queryFunction: () => _futureStudyDetails,
                builder: (_context, study) {
                  context.read<AppState>().selectedStudy = study;
                  return Container();
                }),
          ],
        ),
      )),
      bottomNavigationBar: BottomOnboardingNavigation(
        onNext: () => navigateToEligibilityCheck(context),
      ),
    );
  }
}
