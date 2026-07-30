import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:studyu_app/app_router.dart';
import 'package:studyu_app/l10n/app_localizations.dart';
import 'package:studyu_app/models/app_state.dart';
import 'package:studyu_app/screens/study/onboarding/onboarding_progress.dart';
import 'package:studyu_app/widgets/bottom_onboarding_navigation.dart';
import 'package:studyu_app/widgets/intervention_card.dart';
import 'package:studyu_app/widgets/study_onboarding_description.dart';
import 'package:studyu_core/core.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class InterventionSelectionScreen extends StatefulWidget {
  const InterventionSelectionScreen({super.key});

  @override
  State<InterventionSelectionScreen> createState() =>
      _InterventionSelectionScreenState();
}

class _InterventionSelectionScreenState
    extends State<InterventionSelectionScreen> {
  final List<String> selectedInterventionIds = [];
  Study? selectedStudy;

  @override
  void initState() {
    super.initState();
    selectedStudy = context.read<AppState>().selectedStudy;
  }

  Widget _buildInterventionSelectionList() {
    final interventions = selectedStudy?.interventions;
    if (interventions == null || interventions.isEmpty) {
      return Text(AppLocalizations.of(context)!.no_interventions_available);
    }

    return ListView.builder(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      itemCount: interventions.length,
      itemBuilder: (context, index) => Card(
        child: InterventionCard(
          interventions[index],
          showCheckbox: true,
          showDescription: false,
          selected: selectedInterventionIds.any(
            (interventionId) => interventionId == interventions[index].id,
          ),
          onTap: () => onSelect(interventions[index].id),
        ),
      ),
    );
  }

  void onSelect(String interventionId) {
    setState(() {
      if (!selectedInterventionIds.contains(interventionId)) {
        selectedInterventionIds.add(interventionId);
        if (selectedInterventionIds.length > 2) {
          selectedInterventionIds.removeAt(0);
        }
      } else {
        selectedInterventionIds.removeWhere((id) => id == interventionId);
      }
    });
  }

  Future<void> onFinished() async {
    final appState = context.read<AppState>();
    appState.activeSubject = StudySubject.fromStudy(
      appState.selectedStudy!,
      Supabase.instance.client.auth.currentUser!.id,
      selectedInterventionIds,
      appState.inviteCode,
    );
    context.push('/${RouteNames.journey}');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text(AppLocalizations.of(context)!.intervention_selection_title),
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                StudyOnboardingDescription(
                  text: AppLocalizations.of(
                    context,
                  )!.please_select_interventions,
                  supportingText: AppLocalizations.of(
                    context,
                  )!.please_select_interventions_description,
                ),
                _buildInterventionSelectionList(),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: BottomOnboardingNavigation(
        onNext: selectedInterventionIds.length == 2 ? onFinished : null,
        progress: OnboardingProgress(
          stage: 1,
          progress: selectedInterventionIds.length / 2,
        ),
      ),
    );
  }
}
