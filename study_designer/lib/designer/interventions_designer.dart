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

  List<Intervention> interventions = [Intervention('Xd', 'xd'), Intervention('hi', 'hi')];

  final GlobalKey<FormBuilderState> _editFormKey = GlobalKey<FormBuilderState>();

  void removeIntervention(int index) {
    setState(() {
      interventions.removeAt(index);
    });
  }

  void addIntervention() {
    setState(() {
      interventions.add(Intervention('', ''));
    });
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
            ..._buildInterventionTables(context, interventions),
            RaisedButton.icon(
                textTheme: ButtonTextTheme.primary,
                onPressed: addIntervention,
                icon: Icon(Icons.add),
                color: Colors.green,
                label: Text('Add Intervention')),
          ],
        ),
      ),
    );
  }

  List<dynamic> _buildInterventionTables(BuildContext context, interventions) {
    return interventions
        .asMap()
        .entries
        .map((entry) => Column(children: [
              RaisedButton(
                onPressed: () {
                  showDialog(
                      context: context,
                      builder: (context) {
                        return _buildEditDialog(context, entry.key);
                      });
                },
                child: Text('Edit'),
              ),
              RaisedButton(
                onPressed: () {
                  removeIntervention(entry.key);
                },
                child: Text('Delete'),
              ),
              Table(border: TableBorder.all(), children: [
                TableRow(children: [
                  Column(children: [Text('Name')]),
                  Column(children: [Text(entry.value.name)])
                ]),
                TableRow(children: [
                  Column(children: [Text('Description')]),
                  Column(children: [Text(entry.value.description)])
                ]),
              ]),
            ]))
        .toList();
  }

  Widget _buildEditDialog(BuildContext context, int index) {
    return AlertDialog(
      content: FormBuilder(
        key: _editFormKey,
        autovalidate: true,
        // readonly: true,
        child: Column(
          children: <Widget>[
            FormBuilderTextField(
                attribute: 'name',
                maxLength: 40,
                decoration: InputDecoration(labelText: 'Name'),
                initialValue: interventions[index].name),
            MaterialButton(
              color: Theme.of(context).accentColor,
              onPressed: () {
                _editFormKey.currentState.save();
                if (_editFormKey.currentState.validate()) {
                  setState(() {
                    interventions[index].name = _editFormKey.currentState.value['name'];
                  });
                  print('saved');
                  Navigator.pop(context);
                  // TODO: show dialog "saved"
                } else {
                  print('validation failed');
                }
              },
              child: Text(
                'Save',
                style: TextStyle(color: Colors.white),
              ),
            )
          ],
        ),
      ),
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
