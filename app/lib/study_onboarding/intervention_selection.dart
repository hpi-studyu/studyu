import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:studyou_core/models/models.dart';

import '../database/daos/study_dao.dart';
import '../routes.dart';
import '../util/localization.dart';
import '../util/user.dart';
import 'app_state.dart';
import 'intervention_card.dart';
import 'onboarding_progress.dart';

class InterventionSelectionScreen extends StatefulWidget {
  @override
  _InterventionSelectionScreenState createState() => _InterventionSelectionScreenState();
}

class _InterventionSelectionScreenState extends State<InterventionSelectionScreen> {
  final List<Intervention> selected = [];
  Study selectedStudy;

  @override
  void initState() {
    super.initState();
    selectedStudy = context.read<AppModel>().selectedStudy;
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
            'The effects of these two interventions will be measured and compared during the study.',
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
      itemBuilder: (_context, index) => InterventionCard(interventions[index],
          selected: selected.map((intervention) => intervention.id).contains(interventions[index].id),
          onTap: () => onSelect(interventions[index])),
    );
  }

  void onSelect(Intervention intervention) {
    setState(() {
      if (!selected.map<String>((intervention) => intervention.name).contains(intervention.name)) {
        selected.add(intervention);
        if (selected.length > 2) selected.removeAt(0);
      } else {
        selected.removeWhere((contained) => contained.name == intervention.name);
      }
    });
  }

  Future<void> onFinished() async {
    final model = context.read<AppModel>();
    final userId = await UserUtils.getOrCreateUser().then((user) => user.objectId);
    //TODO add selection of first intervention
    model.activeStudy = model.selectedStudy.extractUserStudy(userId, selected, DateTime.now(), 0);
    final selectedStudyObjectId = await StudyDao.saveUserStudy(model.activeStudy);
    if (selectedStudyObjectId != null) {
      await SharedPreferences.getInstance()
          .then((pref) => pref.setString(UserUtils.selectedStudyObjectIdKey, selectedStudyObjectId));
    }
    Navigator.pushNamed(context, Routes.journey);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(Nof1Localizations.of(context).translate('intervention_selection')),
        actions: [
          IconButton(
            onPressed: (selected.length == 2) ? onFinished : null,
            icon: Icon(MdiIcons.checkBold),
          ),
        ],
        bottom: OnboardingProgress(stage: 1, progress: selected.length / 2),
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
                RaisedButton(
                  onPressed: selected.length == 2 ? onFinished : null,
                  child: Text(Nof1Localizations.of(context).translate('finished')),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
