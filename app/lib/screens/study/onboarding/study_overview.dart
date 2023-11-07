import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:provider/provider.dart';
import 'package:studyu_core/core.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../models/app_state.dart';
import '../../../routes.dart';
import '../../../widgets/bottom_onboarding_navigation.dart';
import '../../../widgets/study_tile.dart';
import '../dashboard/contact_tab/contact_screen.dart';
import 'eligibility_screen.dart';

class StudyOverviewScreen extends StatefulWidget {
  const StudyOverviewScreen({super.key});

  @override
  State<StudyOverviewScreen> createState() => _StudyOverviewScreen();
}

class _StudyOverviewScreen extends State<StudyOverviewScreen> {
  Study? study;

  @override
  void initState() {
    super.initState();
    study = context.read<AppState>().selectedStudy;
  }

  Future<void> navigateToJourney(BuildContext context) async {
    final appState = context.read<AppState>();
    if (appState.preselectedInterventionIds != null) {
      appState.activeSubject = StudySubject.fromStudy(
        appState.selectedStudy!,
        Supabase.instance.client.auth.currentUser!.id,
        appState.preselectedInterventionIds!,
        appState.inviteCode,
      );
      Navigator.pushNamed(context, Routes.journey);
    } else if (study!.interventions.length <= 2) {
      // No need to select interventions if there are only 2 or less
      appState.activeSubject = StudySubject.fromStudy(
        appState.selectedStudy!,
        Supabase.instance.client.auth.currentUser!.id,
        study!.interventions.map((i) => i.id).toList(),
        appState.inviteCode,
      );
      Navigator.pushNamed(context, Routes.journey);
    } else {
      Navigator.pushNamed(context, Routes.interventionSelection);
    }
  }

  Future<void> navigateToEligibilityCheck(BuildContext context) async {
    final study = context.read<AppState>().selectedStudy;
    final result = await Navigator.push<EligibilityResult>(context, EligibilityScreen.routeFor(study: study));
    if (result == null) return;

    if (!mounted) return;
    if (result.eligible) {
      navigateToJourney(context);
    } else {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: Icon(MdiIcons.textLong),
        title: Text(AppLocalizations.of(context)!.study_overview_title),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Hero(
              tag: 'study_tile_${study!.id}',
              child: Material(child: StudyTile.fromStudy(study: study!)),
            ),
            const SizedBox(height: 16),
            StudyDetailsView(study: study),
          ],
        ),
      ),
      bottomNavigationBar: BottomOnboardingNavigation(
        onNext: context.watch<AppState>().selectedStudy!.hasEligibilityCheck
            ? () => navigateToEligibilityCheck(context)
            : () => navigateToJourney(context),
      ),
    );
  }
}

class StudyDetailsView extends StatelessWidget {
  final Study? study;

  const StudyDetailsView({required this.study, super.key});

  double get iconSize => 40;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final baselineLength = study!.schedule.includeBaseline ? study!.schedule.phaseDuration : 0;
    final studyLength = baselineLength +
        study!.schedule.phaseDuration * study!.schedule.numberOfCycles * StudySchedule.numberOfInterventions;
    return Column(
      children: [
        ListTile(
          title: Text(AppLocalizations.of(context)!.intervention_phase_duration),
          subtitle: Text('${study!.schedule.phaseDuration} ${AppLocalizations.of(context)!.days}'),
          leading: Icon(MdiIcons.clock, color: theme.primaryColor, size: iconSize),
        ),
        ListTile(
          title: Text(AppLocalizations.of(context)!.study_length),
          subtitle: Text('$studyLength ${AppLocalizations.of(context)!.days}'),
          leading: Icon(MdiIcons.calendar, color: theme.primaryColor, size: iconSize),
        ),
        const SizedBox(height: 16),
        ContactWidget(
          contact: study!.contact,
          title: AppLocalizations.of(context)!.study_publisher,
          color: theme.colorScheme.secondary,
        ),
      ],
    );
  }
}
