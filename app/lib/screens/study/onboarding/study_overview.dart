import 'package:flutter/material.dart';
import 'package:flutter_material_design_icons/flutter_material_design_icons.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:studyu_app/app_router.dart';
import 'package:studyu_app/l10n/app_localizations.dart';
import 'package:studyu_app/models/app_state.dart';
import 'package:studyu_app/screens/study/dashboard/contact_tab/contact_screen.dart';
import 'package:studyu_app/screens/study/onboarding/eligibility_screen.dart';
import 'package:studyu_app/services/pending_deep_link_service.dart';
import 'package:studyu_app/widgets/bottom_onboarding_navigation.dart';
import 'package:studyu_app/widgets/study_tile.dart';
import 'package:studyu_core/core.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

@visibleForTesting
bool shouldReturnToStudySelection(AppState state) => !state.hasPendingDeepLink;

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

  Future<bool> _ensureTermsAccepted(BuildContext context) async {
    final accepted = await context.push<bool>(
      '/${RouteNames.terms}',
      extra: true,
    );
    return context.mounted && accepted == true;
  }

  Future<void> _continueOnboarding(BuildContext context) async {
    if (!await _ensureTermsAccepted(context) || !context.mounted) return;
    if (study!.hasEligibilityCheck) {
      await navigateToEligibilityCheck(context);
    } else {
      await navigateToJourney(context);
    }
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
      context.push('/${RouteNames.journey}');
    } else if (study!.interventions.length <= 2) {
      // No need to select interventions if there are only 2 or less
      appState.activeSubject = StudySubject.fromStudy(
        appState.selectedStudy!,
        Supabase.instance.client.auth.currentUser!.id,
        study!.interventions.map((i) => i.id).toList(),
        appState.inviteCode,
      );
      context.push('/${RouteNames.journey}');
    } else {
      context.push('/${RouteNames.interventionSelection}');
    }
  }

  Future<void> navigateToEligibilityCheck(BuildContext context) async {
    final study = context.read<AppState>().selectedStudy;
    final result = await context.push<EligibilityResult>(
      '/${RouteNames.eligibilityCheck}',
      extra: EligibilityScreenArguments(
        study: study,
        onEligible: navigateToJourney,
      ),
    );
    if (result == null) return;

    if (!context.mounted) return;
    if (result.eligible) return;

    await PendingDeepLinkService.clear(context.read<AppState>());
    if (!context.mounted) return;
    context.go('/${RouteNames.studySelection}');
  }

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final returnToStudySelection = shouldReturnToStudySelection(appState);

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
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
        backButtonKey: const ValueKey('study_overview_back'),
        onBack: () {
          if (!returnToStudySelection) {
            context.pop();
            return;
          }
          appState
            ..selectedStudy = null
            ..selectedInterventions = null
            ..inviteCode = null
            ..preselectedInterventionIds = null;
          context.go('/${RouteNames.studySelection}');
        },
        nextButtonKey: const ValueKey('study_overview_continue'),
        onNext: () => _continueOnboarding(context),
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
    final studyLength = study!.studyLength;
    return Column(
      children: [
        ListTile(
          title: Text(
            AppLocalizations.of(context)!.intervention_phase_duration,
          ),
          subtitle: Text(
            '${study!.schedule.phaseDuration} ${AppLocalizations.of(context)!.days}',
          ),
          leading: Icon(
            MdiIcons.clock,
            color: theme.primaryColor,
            size: iconSize,
          ),
        ),
        ListTile(
          title: Text(AppLocalizations.of(context)!.study_length),
          subtitle: Text('$studyLength ${AppLocalizations.of(context)!.days}'),
          leading: Icon(
            MdiIcons.calendar,
            color: theme.primaryColor,
            size: iconSize,
          ),
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
