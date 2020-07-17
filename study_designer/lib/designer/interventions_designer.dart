import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:provider/provider.dart';
import 'package:studyou_core/models/models.dart';

import '../models/designer_state.dart';

class InterventionsDesigner extends StatefulWidget {
  @override
  _InterventionsDesignerState createState() => _InterventionsDesignerState();
}

const String keyInterventionName = 'intervention_name_';
const String keyInterventionDescription = 'intervention_description_';

class _InterventionsDesignerState extends State<InterventionsDesigner> {
  Study _draftStudy;

  List<Intervention> interventionsTest = [];

  final GlobalKey<FormBuilderState> _fbKey = GlobalKey<FormBuilderState>();

  void removeIntervention(int index) {
    setState(() {
      // Sets the attribute to null. Currently there is no correct way of removing attributes from the state
      _fbKey.currentState.updateFormAttributeValue(keyInterventionName + index.toString(), null);
      _fbKey.currentState.updateFormAttributeValue(keyInterventionDescription + index.toString(), null);
      // Ideally this would remove the value, but it doesn't do anything. On save() the "removed fields" get restored
      // See https://github.com/danvick/flutter_form_builder/issues/104
      _fbKey.currentState.unregisterFieldKey(keyInterventionName + index.toString());
      _fbKey.currentState.unregisterFieldKey(keyInterventionDescription + index.toString());
      // interventions.removeLast();
    });
    print(_fbKey.currentState.value);
  }

  @override
  Widget build(BuildContext context) {
    _draftStudy = context.watch<DesignerModel>().draftStudy;
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.all(16),
      child: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            RaisedButton.icon(
                textTheme: ButtonTextTheme.primary,
                onPressed: () {
                  setState(() {
                    _draftStudy.studyDetails.interventionSet.interventions.add(Intervention('xd', 'hi'));
                  });
                  print(_draftStudy.studyDetails.interventionSet.interventions);
                },
                icon: Icon(Icons.add),
                color: Colors.green,
                label: Text('Add Intervention')),
            RaisedButton(
              onPressed: () {
                showDialog(context: context, builder: _buildEditDialog);
              },
              child: Text('Edit'),
            ),
            Table(border: TableBorder.all(), children: [
              TableRow(children: [
                Column(children: [Text('Title')]),
                Column(children: [Text(_draftStudy.title)])
              ]),
              TableRow(children: [
                Column(children: [Text('Description')]),
                Column(children: [Text(_draftStudy.description)])
              ]),
            ]),
          ],
        ),
      ),
    );
  }
}

Widget _buildEditDialog(BuildContext context) {
  return AlertDialog();
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
