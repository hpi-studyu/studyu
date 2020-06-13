import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:provider/provider.dart';

import '../database/models/models.dart';
import '../routes.dart';
import '../util/localization.dart';
import 'onboarding_model.dart';

class InterventionSelectionScreen extends StatefulWidget {
  @override
  _InterventionSelectionScreenState createState() => _InterventionSelectionScreenState();
}

class _InterventionSelectionScreenState extends State<InterventionSelectionScreen> {
  final List<Intervention> selected = [];
  Study selectedStudy;

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

  @override
  void initState() {
    super.initState();
    selectedStudy = context.read<OnboardingModel>().selectedStudy;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
        appBar: AppBar(
          title: Text(Nof1Localizations.of(context).translate('intervention_selection')),
        ),
        body: SingleChildScrollView(
            scrollDirection: Axis.vertical,
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(8),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Center(
                      child: Text(
                        Nof1Localizations.of(context).translate('please_select_interventions'),
                        style: theme.textTheme.headline5,
                      ),
                    ),
                    SizedBox(height: 20),
                    selectedStudy.studyDetails != null &&
                            selectedStudy.studyDetails.interventionSet.interventions.isNotEmpty
                        ? buildInterventionSelectionList(selectedStudy.studyDetails.interventionSet.interventions)
                        : Text(Nof1Localizations.of(context).translate('no_interventions_available')),
                    SizedBox(height: 20),
                    RaisedButton(
                      onPressed: selected.length == 2
                          ? () {
                              context.read<OnboardingModel>().selectedInterventions = selected;
                              Navigator.pushNamed(context, Routes.journey);
                            }
                          : null,
                      child: Text(Nof1Localizations.of(context).translate('finished')),
                    ),
                  ],
                ),
              ),
            )));
  }
}
