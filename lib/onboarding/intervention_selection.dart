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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: FutureBuilder(
          future: StudyDao().getStudyDetails(widget.study),
          builder: (_context, snapshot) {
            final theme = Theme.of(context);
            return snapshot.hasData
                ? SingleChildScrollView(
                    scrollDirection: Axis.vertical,
                    child: Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Center(
                            child: Text(
                              'Please select 2 interventions to apply during the study.',
                              style: theme.textTheme.headline5,
                            ),
                          ),
                          SizedBox(
                            height: 20,
                          ),
                          ListView.builder(
                              shrinkWrap: true,
                              itemCount: snapshot.data.interventions.length,
                              itemBuilder: (_context, index) {
                                final intervention = snapshot.data.interventions[index];
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
                                        selected.removeWhere((contained) => contained.name == intervention.name);
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
                              }),
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
                    ))
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
