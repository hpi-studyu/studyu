import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:provider/provider.dart';
import 'package:studyou_core/core.dart';

import '../../../models/app_state.dart';
import '../../../routes.dart';
import '../../../widgets/bottom_onboarding_navigation.dart';
import '../../../widgets/study_tile.dart';
import '../dashboard/contact_tab/contact_screen.dart';
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
    study = context.read<AppState>().selectedStudy;
  }

  Future<void> navigateToEligibilityCheck(BuildContext context) async {
    final study = context.read<AppState>().selectedStudy;
    final result = await Navigator.push<EligibilityResult>(context, EligibilityScreen.routeFor(study: study));
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
        leading: Icon(MdiIcons.textSubject),
        title: Text(AppLocalizations.of(context).study_overview_title),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Hero(
              tag: 'study_tile_${study.id}',
              child: Material(child: StudyTile.fromStudy(study: study)),
            ),
            SizedBox(height: 16),
            RetryFutureBuilder<Study>(
              tryFunction: () => SupabaseQuery.getById<Study>(study.id),
              successBuilder: (context, study) {
                context.read<AppState>().selectedStudy = study;
                return StudyDetailsView(study: study);
              },
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomOnboardingNavigation(
        onNext: () => navigateToEligibilityCheck(context),
      ),
    );
  }
}

class StudyDetailsView extends StatelessWidget {
  final Study study;

  const StudyDetailsView({@required this.study, Key key}) : super(key: key);

  double get iconSize => 40;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final baselineLength = study.schedule.includeBaseline ? study.schedule.phaseDuration : 0;
    final studyLength =
        baselineLength + study.schedule.phaseDuration * study.schedule.numberOfCycles * StudySchedule.numberOfPhases;
    return Column(
      children: [
        ListTile(
          title: Text('Intervention phase duration'),
          subtitle: Text('${study.schedule.phaseDuration} days'),
          leading: Icon(MdiIcons.clock, color: theme.primaryColor, size: iconSize),
        ),
        ListTile(
          title: Text('Minimum study length'),
          subtitle: Text('$studyLength days'),
          leading: Icon(MdiIcons.calendar, color: theme.primaryColor, size: iconSize),
        ),
        SizedBox(height: 16),
        ContactWidget(
          contact: study.contact,
          title: 'Study Publisher',
          color: theme.accentColor,
        ),
      ],
    );
  }
}
