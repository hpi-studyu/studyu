import 'dart:async';

import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

import '../dashboard/dashboard.dart';
import '../database/daos/study_dao.dart';
import '../database/models/models.dart';
import '../routes.dart';
import '../util/localization.dart';

class InterventionSelectionScreenArguments {
  final Study study;

  const InterventionSelectionScreenArguments(this.study);
}

class InterventionSelectionScreen extends StatefulWidget {
  final Study study;

  const InterventionSelectionScreen(this.study, {Key key}) : super(key: key);

  factory InterventionSelectionScreen.fromRouteArgs(InterventionSelectionScreenArguments args) =>
      InterventionSelectionScreen(args.study);

  @override
  _InterventionSelectionScreenState createState() => _InterventionSelectionScreenState();
}

class _InterventionSelectionScreenState extends State<InterventionSelectionScreen> {
  final List<Intervention> selected = [];

  void getConsentAndNavigateToDashboard(BuildContext context, List<Intervention> selected) async {
    final consentGiven = await Navigator.pushNamed(context, Routes.consent);
    if (consentGiven) {
      Navigator.pushNamed(context, Routes.dashboard, arguments: DashboardScreenArguments(selected));
    } else {
      Scaffold.of(context).showSnackBar(SnackBar(
        content: Text('You did not give consent'),
        duration: Duration(seconds: 30),
      ));
    }
  }

  Widget buildInterventionSelectionList(List<Intervention> interventions) {
    final theme = Theme.of(context);
    return ListView.builder(
        shrinkWrap: true,
        itemCount: interventions.length,
        itemBuilder: (_context, index) {
          final intervention = interventions[index];
          return ListTile(
            contentPadding: EdgeInsets.all(16),
            onTap: () {
              setState(() {
                if (!selected.map<String>((intervention) => intervention.name).contains(intervention.name)) {
                  selected.add(intervention);
                  if (selected.length > 2) selected.removeAt(0);
                } else {
                  selected.removeWhere((contained) => contained.name == intervention.name);
                }
              });
            },
            title: Center(
              child: Text(intervention.name, style: theme.textTheme.headline6.copyWith(color: theme.primaryColor)),
            ),
            trailing: selected.map<String>((intervention) => intervention.name).contains(intervention.name)
                ? Icon(MdiIcons.check)
                : null,
          );
        });
  }

  Widget buildInterventionSelection(Study study) {
    final theme = Theme.of(context);

    return SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Center(
                  child: Text(
                    'Please select 1 or 2 interventions to apply during the study.',
                    style: theme.textTheme.headline5,
                  ),
                ),
                SizedBox(
                  height: 20,
                ),
                study.studyDetails != null && study.studyDetails.interventionSet.interventions.isNotEmpty
                    ? buildInterventionSelectionList(study.studyDetails.interventionSet.interventions)
                    : Text('No interventions available.'),
                SizedBox(
                  height: 20,
                ),
                RaisedButton(
                  child: Text(Nof1Localizations.of(context).translate('finished')),
                  onPressed: selected.length == 2
                      ? () =>
                          getConsentAndNavigateToDashboard(context, selected)
                      : null,
                ),
              ],
            ),
          ),
        ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: FutureBuilder(
          future: StudyDao().getStudyWithStudyDetails(widget.study),
          builder: (_context, snapshot) {
            if (!snapshot.hasData) {
              return Center(
                child: Column(mainAxisSize: MainAxisSize.min, children: [
                  Text('Loading interventions'),
                  SizedBox(height: 20),
                  CircularProgressIndicator(),
                ]),
              );
            }
            if (snapshot.hasError) {
              Timer(Duration(seconds: 4), () => Navigator.pop(context));
              return Center(child: Text('An error occurred!'));
            }

            return buildInterventionSelection(snapshot.data as Study);
          },
        ),
      ),
    );
  }
}
