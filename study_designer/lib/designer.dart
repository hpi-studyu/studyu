import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';

class Designer extends StatefulWidget {
  @override
  _DesignerState createState() => _DesignerState();
}

const String keyInterventionName = 'intervention_name_';
const String keyInterventionDescription = 'intervention_description_';

class _DesignerState extends State<Designer> {
  final GlobalKey<FormBuilderState> _fbKey = GlobalKey<FormBuilderState>();

  List<Widget> interventions = [];

  void addIntervention() {
    setState(() {
      interventions.add(InterventionField(index: interventions.length + 1));
    });
  }

  void removeIntervention(int index) {
    setState(() {
      // Sets the attribute to null. Currently there is no correct way of removing attributes from the state
      _fbKey.currentState.updateFormAttributeValue(keyInterventionName + index.toString(), null);
      _fbKey.currentState.updateFormAttributeValue(keyInterventionDescription + index.toString(), null);
      // Ideally this would remove the value, but it doesn't do anything. On save() the "removed fields" get restored
      // See https://github.com/danvick/flutter_form_builder/issues/104
      _fbKey.currentState.unregisterFieldKey(keyInterventionName + index.toString());
      _fbKey.currentState.unregisterFieldKey(keyInterventionDescription + index.toString());
      interventions.removeLast();
    });
    print(_fbKey.currentState.value);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text('Create New Study'),
      ),
      body: Row(children: [
        NavigationRail(
          selectedIndex: 0,
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
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: SingleChildScrollView(
              child: Column(
                children: <Widget>[
                  RaisedButton(
                    onPressed: () {
                      showDialog(
                          context: context,
                          builder: (context) {
                            return AlertDialog(content: Text('hi'));
                          });
                    },
                    child: Text('Open Popup'),
                  ),
                  FormBuilder(
                    key: _fbKey,
                    autovalidate: true,
                    // readonly: true,
                    child: Column(
                      children: <Widget>[
                        FormBuilderTextField(
                          attribute: 'name',
                          maxLength: 40,
                          decoration: InputDecoration(labelText: 'Name'),
                        ),
                        FormBuilderTextField(
                          attribute: 'description',
                          decoration: InputDecoration(labelText: 'Description'),
                        ),
                        Text('Interventions', style: theme.textTheme.subtitle1),
                        ...interventions,
                        Row(
                          children: [
                            RaisedButton.icon(
                                textTheme: ButtonTextTheme.primary,
                                onPressed: addIntervention,
                                icon: Icon(Icons.add),
                                color: Colors.green,
                                label: Text('Add Intervention')),
                            SizedBox(width: 20),
                            RaisedButton.icon(
                                textTheme: ButtonTextTheme.primary,
                                onPressed: () => removeIntervention(interventions.length - 1),
                                icon: Icon(Icons.remove),
                                color: Colors.red,
                                label: Text('Remove Intervention')),
                          ],
                        )
                      ],
                    ),
                  ),
                  SizedBox(height: 20),
                  Row(
                    children: <Widget>[
                      Expanded(
                        child: MaterialButton(
                          color: Theme.of(context).accentColor,
                          onPressed: () {
                            _fbKey.currentState.save();
                            if (_fbKey.currentState.validate()) {
                              print(_fbKey.currentState.value);
                            } else {
                              print('validation failed');
                            }
                          },
                          child: Text(
                            'Submit',
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ),
                      SizedBox(
                        width: 20,
                      ),
                      Expanded(
                        child: MaterialButton(
                          color: Theme.of(context).accentColor,
                          onPressed: () {
                            _fbKey.currentState.reset();
                          },
                          child: Text(
                            'Reset',
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ),
                    ],
                  )
                ],
              ),
            ),
          ),
        )
      ]),
    );
  }
}

class InterventionField extends StatelessWidget {
  final int index;

  const InterventionField({Key key, this.index}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text('Intervention $index'),
        SizedBox(height: 16),
        FormBuilderTextField(
          attribute: 'intervention_name_$index',
          maxLength: 30,
          decoration: InputDecoration(labelText: 'Name'),
        ),
        FormBuilderTextField(
          attribute: 'intervention_description_$index',
          decoration: InputDecoration(labelText: 'Description'),
        ),
      ],
    );
  }
}
