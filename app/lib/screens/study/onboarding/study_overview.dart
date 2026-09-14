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
import 'package:studyu_app/widgets/onboarding_shell.dart';
import 'package:studyu_app/widgets/study_tile.dart';
import 'package:studyu_core/core.dart';

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
    await context.push<void>(
      '/${RouteNames.terms}',
      extra: TermsScreenArguments(onAccepted: _continueAfterTerms),
    );
  }

  Future<void> _continueAfterTerms(BuildContext context) async {
    if (study!.hasEligibilityCheck) {
      await navigateToEligibilityCheck(context);
    } else {
      await continueAfterEligibility(context);
    }
  }

  Future<void> navigateToEligibilityCheck(BuildContext context) async {
    await context.push<void>(
      '/${RouteNames.eligibilityCheck}',
      extra: EligibilityScreenArguments(
        study: context.read<AppState>().selectedStudy,
        onEligible: continueAfterEligibility,
      ),
    );
  }

  void _clearStudySelection(AppState appState) {
    appState
      ..selectedStudy = null
      ..selectedInterventions = null
      ..inviteCode = null
      ..preselectedInterventionIds = null;
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
    final navNotifier = OnboardingNavNotifier.maybeOf(context);
    final navConfig = OnboardingNavConfig(
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
    navNotifier?.register(this, '/${RouteNames.studyOverview}', navConfig);

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
      bottomNavigationBar: navNotifier == null ? navConfig.build() : null,
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
