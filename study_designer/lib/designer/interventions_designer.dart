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

  final GlobalKey<FormBuilderState> _fbKey = GlobalKey<FormBuilderState>();

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
                  showDialog(context: context, builder: _buildEditDialog);
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
              ]),
            ]))
        .toList();
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
