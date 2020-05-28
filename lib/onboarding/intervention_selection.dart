import 'dart:async';

import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

import '../dashboard/dashboard.dart';
import '../database/daos/study_dao.dart';
import '../database/models/models.dart';
import '../util/localization.dart';

class InterventionSelection extends StatefulWidget {
  final Study study;

  const InterventionSelection({Key key, this.study}) : super(key: key);

  @override
  _InterventionSelectionState createState() => _InterventionSelectionState();
}

class _InterventionSelectionState extends State<InterventionSelection> {
  final List<Intervention> selected = [];

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
                if (!selected
                    .map<String>((intervention) => intervention.name)
                    .contains(intervention.name)) {
                  selected.add(intervention);
                  if (selected.length > 2) selected.removeAt(0);
                } else {
                  selected
                      .removeWhere((contained) => contained.name == intervention.name);
                }
              });
            },
            title: Center(
              child: Text(intervention.name,
                  style: theme.textTheme.headline6.copyWith(color: theme.primaryColor)),
            ),
            trailing: selected
                .map<String>((intervention) => intervention.name)
                .contains(intervention.name)
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
                study.studyDetails != null &&
                    study.studyDetails.interventions.isNotEmpty
                    ? buildInterventionSelectionList(study.studyDetails.interventions)
                    : Text('No interventions available.'),
                SizedBox(
                  height: 20,
                ),
                RaisedButton(
                  child: Text(Nof1Localizations.of(context).translate('finished')),
                  onPressed: () => Navigator.of(context).pushReplacementNamed(DashboardScreen.routeName,
                      arguments: DashboardScreenArguments(selected)),
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
            if (snapshot.hasError) {
              Timer(Duration(seconds: 4,), () => Navigator.pushReplacementNamed(context, '/studySelection'));
              return Center(
                child: Text('An error occurred!'),
              );
            }
            return snapshot.hasData
                ? buildInterventionSelection(snapshot.data as Study)
                : Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text('Loading interventions'),
                        SizedBox(
                          height: 20,
                        ),
                        CircularProgressIndicator(),
                      ],
                    ),
                  );
          },
        ),
      ),
    );
  }
}
