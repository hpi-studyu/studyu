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
import '../../../widgets/study_tile.dart';
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
    _futureStudyDetails = StudyQueries.getStudyWithDetails(study);
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
              child: Material(child: StudyTile.fromStudy(study: study)),
            ),
            SizedBox(height: 16),
            ParseFetchOneFutureBuilder<ParseStudy>(
                queryFunction: () => _futureStudyDetails,
                builder: (_context, study) {
                  context.read<AppState>().selectedStudy = study;
                  return StudyDetailsView(studyDetails: study.studyDetails);
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

class StudyDetailsView extends StatelessWidget {
  final StudyDetailsBase studyDetails;

  const StudyDetailsView({@required this.studyDetails, Key key}) : super(key: key);

  final double iconSize = 40;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final baselineLength = studyDetails.schedule.includeBaseline ? studyDetails.schedule.phaseDuration : 0;
    final studyLength = baselineLength +
        studyDetails.schedule.phaseDuration * studyDetails.schedule.numberOfCycles * StudySchedule.numberOfPhases;
    return Column(
      children: [
        ListTile(
          title: Text('Intervention phase duration'),
          subtitle: Text('${studyDetails.schedule.phaseDuration} days'),
          leading: Icon(
            MdiIcons.clock,
            color: theme.accentColor,
            size: iconSize,
          ),
        ),
        SizedBox(height: 16),
        ListTile(
          title: Text('Minimum study length'),
          subtitle: Text('$studyLength days'),
          leading: Icon(MdiIcons.calendar, color: theme.accentColor, size: iconSize),
        ),
        SizedBox(height: 16),
        ListTile(
          title: Text('Research Facility'),
          subtitle: Text('Hasso Plattner Institute'),
          leading: Icon(MdiIcons.hospitalBuilding, color: theme.accentColor, size: iconSize),
          trailing: Image.asset('assets/images/hpi.png', height: 200),
        ),
        SizedBox(height: 16),
        ListTile(
          title: Text('Responsible Researchers'),
          subtitle: Text('Darius Rüther, Manisha Manaswini, Alexander Zenner, Florian Henschel, Fabian Pottbäcker, Nils Strelow'),
          leading: Icon(MdiIcons.doctor, color: theme.accentColor, size: iconSize),
        ),
      ],
    );
  }
}
