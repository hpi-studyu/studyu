import 'package:flutter/material.dart';

class StudyDesigner extends StatefulWidget {
  @override
  _StudyDesigner createState() => _StudyDesigner();
}

class _StudyDesigner extends State<StudyDesigner> {
  final Map<String, dynamic> _metaData = {};
  List<Map> _interventions = [];

  @override
  void initState() {
    super.initState();
    _interventions..add({'name': '', 'description': ''})..add({'name': '', 'description': ''});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('Create New Study'),
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: <Widget>[
                ..._buildMetaForm(context),
                ...buildInterventionForm(context),
                _buildSubmitButton(),
              ],
            ),
          ),
        ));
  }

  List<Widget> _buildMetaForm(BuildContext context) {
    final theme = Theme.of(context);

    return <Widget>[
      Text(
        'Study Meta Data',
        style: theme.textTheme.subtitle1,
      ),
      TextFormField(
        initialValue: _metaData['name'],
        decoration: InputDecoration(labelText: 'Name'),
        onChanged: (text) {
          _metaData['name'] = text;
        },
      ),
      TextField(
        decoration: InputDecoration(labelText: 'Description'),
        onChanged: (text) {
          _metaData['description'] = text;
        },
      )
    ];
  }

  List<Widget> buildInterventionForm(BuildContext context) {
    final theme = Theme.of(context);

    return <Widget>[
      Text(
        'Interventions',
        style: theme.textTheme.subtitle1,
      ),
      ...buildInterventions(context),
      _buildAddInterventionButton(),
      RaisedButton(
        onPressed: () {
          setState(() {
            final interventions = _interventions..removeAt(0);
            _interventions = interventions;
          });
        },
        child: Text('Remove'),
      )
    ];
  }

  List<dynamic> buildInterventions(BuildContext context) {
    final theme = Theme.of(context);

    return _interventions.asMap().entries.map((entry) {
      final interventionNumber = (entry.key + 1).toString();
      return Container(
          margin: EdgeInsets.all(10),
          key: Key(interventionNumber),
          child: Column(children: <Widget>[
            Text(
              'Intervention $interventionNumber',
              style: theme.textTheme.subtitle1,
            ),
            TextFormField(
              initialValue: _interventions[entry.key]['name'],
              decoration: InputDecoration(labelText: 'Intervention $interventionNumber Name'),
              onChanged: (text) {
                _interventions[entry.key]['name'] = text;
              },
            ),
            TextFormField(
              initialValue: _interventions[entry.key]['descriptions'],
              decoration: InputDecoration(labelText: 'Intervention $interventionNumber Descriptions'),
              onChanged: (text) {
                _interventions[entry.key]['descriptions'] = text;
              },
            )
          ]));
    }).toList();
  }

  Widget _buildAddInterventionButton() {
    return RaisedButton(
      onPressed: () {
        setState(() {
          final interventions = _interventions..add({'name': '', 'description': ''});
          _interventions = interventions;
        });
      },
      child: Text('Add'),
    );
  }

  Widget _buildSubmitButton() {
    return RaisedButton(
      onPressed: () {
        print(_metaData);
        print(_interventions);
      },
      child: Text('PRINT'),
    );
  }
}
