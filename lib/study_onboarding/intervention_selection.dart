import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../database/daos/study_dao.dart';
import '../database/models/models.dart';
import '../routes.dart';
import '../util/localization.dart';
import '../util/user.dart';
import 'app_state.dart';
import 'intervention_card.dart';

class InterventionSelectionScreen extends StatefulWidget {
  @override
  _InterventionSelectionScreenState createState() => _InterventionSelectionScreenState();
}

class _InterventionSelectionScreenState extends State<InterventionSelectionScreen> {
  final List<Intervention> selected = [];
  Study selectedStudy;

  Widget buildInterventionSelectionList(List<Intervention> interventions) {
    return ListView.builder(
      physics: NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      itemCount: interventions.length,
      itemBuilder: (_context, index) => InterventionCard(
        interventions[index],
        selected: selected.map((intervention) => intervention.id).contains(interventions[index].id),
        onTap: () {
          setState(() {
            if (!selected.map<String>((intervention) => intervention.name).contains(interventions[index].name)) {
              selected.add(interventions[index]);
              if (selected.length > 2) selected.removeAt(0);
            } else {
              selected.removeWhere((contained) => contained.name == interventions[index].name);
            }
          });
        },
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    selectedStudy = context.read<AppModel>().selectedStudy;
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
          bottom: PreferredSize(
            preferredSize: Size.fromHeight(4),
            child: Row(
              children: [
                Expanded(child: LinearProgressIndicator(value: 1)),
                SizedBox(width: 4),
                Expanded(child: LinearProgressIndicator(value: selected.length / 2)),
                SizedBox(width: 4),
                Expanded(child: LinearProgressIndicator(value: 0)),
              ],
            ),
          ),
        ),
        body: SingleChildScrollView(
            scrollDirection: Axis.vertical,
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(8),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Padding(
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
                    ),
                    selectedStudy.studyDetails != null &&
                            selectedStudy.studyDetails.interventionSet.interventions.isNotEmpty
                        ? buildInterventionSelectionList(selectedStudy.studyDetails.interventionSet.interventions)
                        : Text(Nof1Localizations.of(context).translate('no_interventions_available')),
                    SizedBox(height: 20),
                    RaisedButton(
                      onPressed: selected.length == 2 ? onFinished : null,
                      child: Text(Nof1Localizations.of(context).translate('finished')),
                    ),
                  ],
                ),
              ),
            )));
  }
}
