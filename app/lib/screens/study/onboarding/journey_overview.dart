import 'package:StudYou/widgets/study_tile.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:provider/provider.dart';
import 'package:studyou_core/models/models.dart';

import '../../../models/app_state.dart';
import '../../../routes.dart';
import '../../../util/localization.dart';
import '../../../widgets/bottom_onboarding_navigation.dart';
import 'onboarding_progress.dart';

class JourneyOverviewScreen extends StatefulWidget {
  @override
  _JourneyOverviewScreen createState() => _JourneyOverviewScreen();
}

class _JourneyOverviewScreen extends State<JourneyOverviewScreen> {
  ParseUserStudy study;

  Future<void> getConsentAndNavigateToDashboard(BuildContext context) async {
    final consentGiven = await Navigator.pushNamed(context, Routes.consent);
    if (consentGiven != null && consentGiven) {
      Navigator.pushNamed(context, Routes.kickoff);
    } else {
      Scaffold.of(context).showSnackBar(SnackBar(
        content: Text(Nof1Localizations.of(context).translate('user_did_not_give_consent')),
        duration: Duration(seconds: 30),
      ));
    }
  }

  @override
  void initState() {
    super.initState();
    study = context.read<AppState>().activeStudy;
  }

  List<Widget> buildJourney() {
    return study.interventionOrder
        .map((id) => Padding(
            padding: const EdgeInsets.all(15),
            child: Column(children: [
              Text(study.interventionSet.interventions
                      .firstWhere((intervention) => intervention.id == id, orElse: () => null)
                      ?.name ??
                  '')
            ])))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(study.title),
        leading: Icon(MdiIcons.fromString(study.iconName)),
      ),
      body: Builder(builder: (_context) {
        return Center(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  StudyTile.fromUserStudy(study: study),
                  SizedBox(height: 40),
                  ...buildJourney(),
                ],
              ),
            ),
          ),
        );
      }),
      bottomNavigationBar: BottomOnboardingNavigation(
        onNext: () => getConsentAndNavigateToDashboard(context),
        progress: OnboardingProgress(stage: 2, progress: 0.5),
      ),
    );
  }
}
