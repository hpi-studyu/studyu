import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:provider/provider.dart';
import 'package:studyou_core/models/models.dart';
import 'package:studyou_core/util/localization.dart';

import '../../../models/app_state.dart';
import '../../../routes.dart';
import '../../../util/notifications.dart';
import '../../../widgets/bottom_onboarding_navigation.dart';
import '../../../widgets/intervention_card.dart';
import 'onboarding_progress.dart';

class InterventionSelectionScreen extends StatefulWidget {
  @override
  _InterventionSelectionScreenState createState() => _InterventionSelectionScreenState();
}

class _InterventionSelectionScreenState extends State<InterventionSelectionScreen> {
  final List<Intervention> selectedInterventions = [];
  ParseStudy selectedStudy;

  @override
  void initState() {
    super.initState();
    selectedStudy = context.read<AppState>().selectedStudy;
  }

  Widget _buildInterventionSelectionExplanation(ThemeData theme) {
    return Padding(
      padding: EdgeInsets.all(8),
      child: Column(
        children: [
          Text(
            Nof1Localizations.of(context).translate('please_select_interventions'),
            style: theme.textTheme.subtitle1,
          ),
          SizedBox(height: 8),
          Text(
            Nof1Localizations.of(context).translate('please_select_interventions_description'),
            style: theme.textTheme.bodyText2.copyWith(color: theme.textTheme.caption.color),
          ),
        ],
      ),
    );
  }

  Widget _buildInterventionSelectionList() {
    final interventions = selectedStudy.studyDetails?.interventionSet?.interventions;
    if (interventions == null || interventions.isEmpty) {
      return Text(Nof1Localizations.of(context).translate('no_interventions_available'));
    }

    return ListView.builder(
      physics: NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      itemCount: interventions.length,
      itemBuilder: (_context, index) => Card(
        child: InterventionCard(interventions[index],
            showCheckbox: true,
            showDescription: false,
            selected: selectedInterventions.any((intervention) => intervention.id == interventions[index].id),
            onTap: () => onSelect(interventions[index])),
      ),
    );
  }

  void onSelect(Intervention intervention) {
    setState(() {
      if (!selectedInterventions.map<String>((intervention) => intervention.name).contains(intervention.name)) {
        selectedInterventions.add(intervention);
        if (selectedInterventions.length > 2) selectedInterventions.removeAt(0);
      } else {
        selectedInterventions.removeWhere((contained) => contained.name == intervention.name);
      }
    });
  }

  Future<void> onFinished() async {
    final model = context.read<AppState>();
    model.activeStudy = model.selectedStudy.extractUserStudy(null, selectedInterventions, DateTime.now(), 0);
    scheduleStudyNotifications(context);
    Navigator.pushNamed(context, Routes.journey);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(Nof1Localizations.of(context).translate('intervention_selection_title')),
        leading: Icon(MdiIcons.formatListChecks),
      ),
      body: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildInterventionSelectionExplanation(theme),
                _buildInterventionSelectionList(),
                SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: BottomOnboardingNavigation(
        onNext: selectedInterventions.length == 2 ? onFinished : null,
        progress: OnboardingProgress(stage: 1, progress: selectedInterventions.length / 2),
      ),
    );
  }
}
