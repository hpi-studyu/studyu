import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:study_designer/designer/interventions_designer/task_card.dart';
import 'package:studyou_core/models/interventions/intervention.dart';
import 'package:studyou_core/models/interventions/interventions.dart';
import 'package:uuid/uuid.dart';

class InterventionCard extends StatefulWidget {
  final Intervention intervention;
  final void Function() remove;

  const InterventionCard({@required this.intervention, @required this.remove, Key key}) : super(key: key);

  @override
  _InterventionCardState createState() => _InterventionCardState();
}

class _InterventionCardState extends State<InterventionCard> {
  int selectedTaskIndex;

  final GlobalKey<FormBuilderState> _editFormKey = GlobalKey<FormBuilderState>();

  void _addCheckMarkTask() {
    setState(() {
      final task = CheckmarkTask()
        ..id = Uuid().v4()
        ..title = '';
      widget.intervention.tasks.add(task);
    });
  }

  void _removeTask(taskIndex) {
    setState(() {
      selectedTaskIndex = null;
      widget.intervention.tasks.removeAt(taskIndex);
    });
  }

  void _selectTask(index) {
    setState(() {
      selectedTaskIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final cardContent = <Widget>[];

    cardContent.add(_buildDeleteButton());

    cardContent.add(_buildEditMetaDataForm());

    cardContent.addAll(_buildTaskCards());

    cardContent.add(_buildCardFooter());

    return Card(margin: EdgeInsets.all(10.0), child: Column(children: cardContent));
  }

  Widget _buildDeleteButton() {
    return ButtonBar(
      children: <Widget>[
        FlatButton(
          onPressed: () {
            widget.remove();
          },
          child: const Text('Delete'),
        ),
      ],
    );
  }

  List<Widget> _buildTaskCards() {
    return widget.intervention.tasks
        .asMap()
        .entries
        .map((entry) => TaskCard(key: UniqueKey(), task: entry.value, remove: () => _removeTask(entry.key)))
        .toList();
  }

  Widget _buildEditMetaDataForm() {
    return FormBuilder(
        key: _editFormKey,
        autovalidate: true,
        // readonly: true,
        child: Column(
          children: <Widget>[
            FormBuilderTextField(
                onChanged: (value) {
                  saveFormChanges();
                },
                attribute: 'name',
                maxLength: 40,
                decoration: InputDecoration(labelText: 'Name'),
                initialValue: widget.intervention.name),
            FormBuilderTextField(
                onChanged: (value) {
                  saveFormChanges();
                },
                attribute: 'description',
                decoration: InputDecoration(labelText: 'Description'),
                initialValue: widget.intervention.description),
          ],
        ));
  }

  void saveFormChanges() {
    _editFormKey.currentState.save();
    if (_editFormKey.currentState.validate()) {
      setState(() {
        widget.intervention.name = _editFormKey.currentState.value['name'];
        widget.intervention.description = _editFormKey.currentState.value['description'];
      });
    }
  }

  Widget _buildCardFooter() {
    return ButtonBar(
      children: <Widget>[
        FlatButton(
          onPressed: _addCheckMarkTask,
          child: const Text('Add checkmark task'),
        ),
      ],
    );
  }
}
