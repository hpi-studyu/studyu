import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

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
      ),
    );
  }
}
