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

  Widget buildInterventionSelectionList(List<Intervention> interventions) {
    final theme = Theme.of(context);
    return ListView.builder(
        physics: NeverScrollableScrollPhysics(),
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

  Widget buildInterventionSelection(BuildContext context, Study study) {
    final theme = Theme.of(context);
    return Scaffold(
        appBar: AppBar(
          title: Text(Nof1Localizations.of(context).translate('intervention_selection')),
        ),
        body: SingleChildScrollView(
            scrollDirection: Axis.vertical,
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Center(
                      child: Text(
                        Nof1Localizations.of(context).translate('please_select_interventions'),
                        style: theme.textTheme.headline5,
                      ),
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    study.studyDetails != null && study.studyDetails.interventionSet.interventions.isNotEmpty
                        ? buildInterventionSelectionList(study.studyDetails.interventionSet.interventions)
                        : Text(Nof1Localizations.of(context).translate('no_interventions_available')),
                    SizedBox(
                      height: 20,
                    ),
                    RaisedButton(
                      child: Text(Nof1Localizations.of(context).translate('finished')),
                      onPressed: selected.length == 2
                          ? () => Navigator.pushNamed(context, Routes.journey,
                              arguments: DashboardScreenArguments(selected))
                          : null,
                    ),
                  ],
                ),
              ),
            )));
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
                  Text(Nof1Localizations.of(context).translate('loading_interventions')),
                  SizedBox(height: 20),
                  CircularProgressIndicator(),
                ]),
              );
            }
            if (snapshot.hasError) {
              Timer(Duration(seconds: 4), () => Navigator.pop(context));
              return Center(child: Text(Nof1Localizations.of(context).translate('error')));
            }

            return buildInterventionSelection(_context, snapshot.data as Study);
          },
        ),
      ),
    );
  }
}
