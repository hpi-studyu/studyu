import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_material_design_icons/flutter_material_design_icons.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:studyu_app/app_router.dart';
import 'package:studyu_app/l10n/app_localizations.dart';
import 'package:studyu_app/models/app_state.dart';
import 'package:studyu_app/screens/app_onboarding/terms.dart';
import 'package:studyu_app/screens/study/dashboard/contact_tab/contact_screen.dart';
import 'package:studyu_app/screens/study/onboarding/eligibility_screen.dart';
import 'package:studyu_app/screens/study/onboarding/onboarding_progress.dart';
import 'package:studyu_app/widgets/bottom_onboarding_navigation.dart';
import 'package:studyu_app/widgets/onboarding_shell.dart';
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

  Future<void> _continueOnboarding(BuildContext context) async {
    final appState = context.read<AppState>();
    // The terms phase is entered only through this action.
    appState.onboardingPhase = StudyOnboardingPhase.terms;
    await context.push<void>(
      '/${RouteNames.terms}',
      extra: TermsScreenArguments(onAccepted: _continueAfterTerms),
    );
    // When the terms screen is popped, the enrollment restarts at the
    // overview phase (unless a later phase has since taken over).
    if (appState.onboardingPhase == StudyOnboardingPhase.terms) {
      appState.onboardingPhase = StudyOnboardingPhase.overview;
    }
  }

  Future<void> _continueAfterTerms(BuildContext context) async {
    // Only the terms-accept callback advances enrollment past the terms
    // phase; informational `/terms` access carries no callback.
    if (context.read<AppState>().onboardingPhase !=
        StudyOnboardingPhase.terms) {
      return;
    }
    if (study!.hasEligibilityCheck) {
      await navigateToEligibilityCheck(context);
    } else {
      await navigateToJourney(context);
    }
  }

  Future<void> navigateToJourney(BuildContext context) async {
    final appState = context.read<AppState>();
    // Defense in depth: never replace a started subject's active study.
    if (!appState.isPreview && appState.activeSubject?.startedAt != null) {
      context.go('/${RouteNames.dashboard}');
      return;
    }
    if (appState.preselectedInterventionIds != null) {
      appState.activeSubject = StudySubject.fromStudy(
        appState.selectedStudy!,
        Supabase.instance.client.auth.currentUser!.id,
        appState.preselectedInterventionIds!,
        appState.inviteCode,
      );
      appState.onboardingPhase = StudyOnboardingPhase.journey;
      context.push('/${RouteNames.journey}');
    } else if (study!.interventions.length <= 2) {
      // No need to select interventions if there are only 2 or less
      appState.activeSubject = StudySubject.fromStudy(
        appState.selectedStudy!,
        Supabase.instance.client.auth.currentUser!.id,
        study!.interventions.map((i) => i.id).toList(),
        appState.inviteCode,
      );
      appState.onboardingPhase = StudyOnboardingPhase.journey;
      context.push('/${RouteNames.journey}');
    } else {
      appState.onboardingPhase = StudyOnboardingPhase.interventionSelection;
      context.push('/${RouteNames.interventionSelection}');
    }
  }

  Future<void> navigateToEligibilityCheck(BuildContext context) async {
    final appState = context.read<AppState>();
    // The eligibility phase is entered only after terms were accepted.
    appState.onboardingPhase = StudyOnboardingPhase.eligibility;
    await context.push<void>(
      '/${RouteNames.eligibilityCheck}',
      extra: EligibilityScreenArguments(
        study: context.read<AppState>().selectedStudy,
        onEligible: navigateToJourney,
      ),
    );
    // When the eligibility check is popped, the participant is back on
    // the terms screen (unless a later phase has since taken over).
    if (appState.onboardingPhase == StudyOnboardingPhase.eligibility) {
      appState.onboardingPhase = StudyOnboardingPhase.terms;
    }
  }

  void _clearStudySelection(AppState appState) {
    appState
      ..selectedStudy = null
      ..selectedInterventions = null
      ..inviteCode = null
      ..preselectedInterventionIds = null
      ..onboardingPhase = null;
  }

  Future<void> _returnToStudySelection(AppState appState) async {
    if (!context.canPop()) {
      _clearStudySelection(appState);
      context.go('/${RouteNames.studySelection}');
      return;
    }

    final route = ModalRoute.of(context);
    context.pop();
    await route?.completed;
    _clearStudySelection(appState);
  }

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final returnToStudySelection = shouldReturnToStudySelection(appState);

    final nav = BottomOnboardingNavigation(
      backButtonKey: const ValueKey('study_overview_back'),
      onBack: () {
        if (!returnToStudySelection) {
          context.pop();
          return;
        }
        unawaited(_returnToStudySelection(appState));
      },
      nextButtonKey: const ValueKey('study_overview_continue'),
      onNext: () => _continueOnboarding(context),
      progress: OnboardingProgress.forPage(appState, OnboardingStep.overview),
    );

    final navNotifier = OnboardingNavNotifier.maybeOf(context);
    if (navNotifier != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        navNotifier.setConfig(OnboardingNavConfig.fromNav(nav));
      });
    }

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text(AppLocalizations.of(context)!.study_overview_title),
      ),
      body: Align(
        alignment: Alignment.topCenter,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 700),
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Hero(
                  tag: 'study_tile_${study!.id}',
                  child: Material(
                    type: MaterialType.transparency,
                    child: StudyTile.fromStudy(study: study!),
                  ),
                ),
                const SizedBox(height: 16),
                StudyDetailsView(study: study),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: navNotifier != null ? null : nav,
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
