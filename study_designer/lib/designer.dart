import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:study_designer/designer/consent_designer.dart';
import 'package:study_designer/designer/eligibility_designer/designer.dart';
import 'package:study_designer/designer/observation_designer/designer.dart';
import 'package:study_designer/designer/publish.dart';
import 'package:study_designer/designer/report_designer.dart';
import 'package:study_designer/designer/schedule_designer.dart';

import 'designer/interventions_designer/designer.dart';
import 'designer/meta_data_designer.dart';
import 'models/designer_state.dart';

class Designer extends StatefulWidget {
  @override
  _DesignerState createState() => _DesignerState();
}

const String keyInterventionName = 'intervention_name_';
const String keyInterventionDescription = 'intervention_description_';

class _DesignerState extends State<Designer> {
  int _selectedIndex = 0;

  final List<Widget> _mywidgets = [
    MetaDataDesigner(),
    InterventionsDesigner(),
    EligibilityDesigner(),
    ObservationDesigner(),
    ScheduleDesigner(),
    ReportDesigner(),
    ConsentDesigner(),
    Publish(),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Provider<DesignerModel>(
      create: (context) => DesignerModel(),
      child: Scaffold(
        appBar: AppBar(
          title: Text('Create New Study'),
        ),
        body: Row(children: [
          NavigationRail(
            selectedIndex: _selectedIndex,
            onDestinationSelected: (index) {
              setState(() {
                _selectedIndex = index;
              });
            },
            labelType: NavigationRailLabelType.all,
            destinations: [
              NavigationRailDestination(
                icon: Icon(Icons.favorite_border),
                selectedIcon: Icon(Icons.favorite),
                label: Text('Meta Data'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.accessibility_new),
                selectedIcon: Icon(Icons.accessibility_new),
                label: Text('Interventions'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.verified_user),
                selectedIcon: Icon(Icons.verified_user),
                label: Text('Eligibility'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.zoom_in),
                selectedIcon: Icon(Icons.zoom_in),
                label: Text('Observations'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.schedule),
                selectedIcon: Icon(Icons.schedule),
                label: Text('Schedule'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.content_paste),
                selectedIcon: Icon(Icons.content_paste),
                label: Text('Report'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.warning),
                selectedIcon: Icon(Icons.warning),
                label: Text('Consent'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.publish),
                selectedIcon: Icon(Icons.publish),
                label: Text('Publish'),
              )
            ],
          ),
          VerticalDivider(thickness: 1, width: 1),
          Expanded(
            child: _mywidgets.elementAt(_selectedIndex),
          )
        ]),
      ),
    );
  }
}
