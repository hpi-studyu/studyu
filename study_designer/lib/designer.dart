import 'package:flutter/material.dart';
import 'package:study_designer/designer/interventions_designer.dart';
import 'package:study_designer/designer/meta_data_designer.dart';
import 'package:studyou_core/models/models.dart';

class Designer extends StatefulWidget {
  @override
  _DesignerState createState() => _DesignerState();
}

const String keyInterventionName = 'intervention_name_';
const String keyInterventionDescription = 'intervention_description_';

class _DesignerState extends State<Designer> {
  Study study;
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    study = Study()..title = 'hi';
  }

  final List<Widget> _mywidgets = [
    MetaDataDesigner(),
    InterventionsDesigner(),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
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
              icon: Icon(Icons.favorite_border),
              selectedIcon: Icon(Icons.favorite),
              label: Text('Interventions'),
            ),
            NavigationRailDestination(
              icon: Icon(Icons.favorite_border),
              selectedIcon: Icon(Icons.favorite),
              label: Text('Eligibility'),
            ),
            NavigationRailDestination(
              icon: Icon(Icons.favorite_border),
              selectedIcon: Icon(Icons.favorite),
              label: Text('Observations'),
            ),
            NavigationRailDestination(
              icon: Icon(Icons.favorite_border),
              selectedIcon: Icon(Icons.favorite),
              label: Text('Schedule'),
            ),
            NavigationRailDestination(
              icon: Icon(Icons.favorite_border),
              selectedIcon: Icon(Icons.favorite),
              label: Text('Report'),
            ),
            NavigationRailDestination(
              icon: Icon(Icons.favorite_border),
              selectedIcon: Icon(Icons.favorite),
              label: Text('Consent'),
            ),
            NavigationRailDestination(
              icon: Icon(Icons.favorite_border),
              selectedIcon: Icon(Icons.favorite),
              label: Text('Publish'),
            )
          ],
        ),
        VerticalDivider(thickness: 1, width: 1),
        Expanded(
          child: _mywidgets.elementAt(_selectedIndex),
        )
      ]),
    );
  }
}
