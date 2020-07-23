import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:provider/provider.dart';
import 'package:study_designer/designer/interventions_designer/task_card.dart';
import 'package:study_designer/models/designer_state.dart';

class InterventionCard extends StatefulWidget {
  final int interventionIndex;
  final bool isEditing;
  final void Function(int interventionIndex) removeIntervention;
  final void Function(int interventionIndex) onTap;

  const InterventionCard(
      {@required this.interventionIndex,
      @required this.removeIntervention,
      @required this.isEditing,
      @required this.onTap,
      Key key})
      : super(key: key);

  @override
  _InterventionCardState createState() => _InterventionCardState();
}

class _InterventionCardState extends State<InterventionCard> {
  LocalIntervention intervention;
  int selectedTaskIndex;

  final GlobalKey<FormBuilderState> _editFormKey = GlobalKey<FormBuilderState>();

  @override
  void initState() {
    super.initState();
    selectedTaskIndex = null;
  }

  void _addCheckMarkTask() {
    setState(() {
      final task = LocalCheckMarkTask()
        ..name = ''
        ..description = ''
        ..schedules = [];
      intervention.tasks.add(task);
    });
    setState(() => selectedTaskIndex = intervention.tasks.length - 1);
  }

  void _removeTask(taskIndex) {
    setState(() {
      setState(() => selectedTaskIndex = null);
      intervention.tasks.removeAt(taskIndex);
    });
  }

  void _selectTask(index) {
    widget.onTap(widget.interventionIndex);
    setState(() {
      selectedTaskIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    intervention = context.watch<DesignerModel>().draftStudy.studyDetails.interventions[widget.interventionIndex];

    final cardContent = <Widget>[];
    cardContent.add(Text('Intervention ' + (widget.interventionIndex + 1).toString()));
    if (widget.isEditing) {
      cardContent.add(_buildDeleteButton());
    }
    if (widget.isEditing && selectedTaskIndex == null) {
      cardContent.add(_buildEditMetaDataForm());
    } else {
      cardContent.add(_buildShowMetaData());
    }
    cardContent.addAll(_buildTaskCards());
    if (widget.isEditing) {
      cardContent.add(_buildCardFooter());
    }

    return GestureDetector(
      onTap: () {
        setState(() => selectedTaskIndex = null);
        if (!widget.isEditing) {
          widget.onTap(widget.interventionIndex);
        }
      },
      child: Card(margin: EdgeInsets.all(10.0), child: Column(children: cardContent)),
    );
  }

  Widget _buildDeleteButton() {
    return ButtonBar(
      children: <Widget>[
        FlatButton(
          onPressed: () {
            widget.removeIntervention(widget.interventionIndex);
          },
          child: const Text('Delete'),
        ),
      ],
    );
  }

  List<Widget> _buildTaskCards() {
    return intervention.tasks
        .asMap()
        .entries
        .map((entry) => TaskCard(
              interventionIndex: widget.interventionIndex,
              taskIndex: entry.key,
              removeTask: _removeTask,
              isEditing: widget.isEditing && entry.key == selectedTaskIndex,
              onTap: _selectTask,
            ))
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
                initialValue: intervention.name),
            FormBuilderTextField(
                onChanged: (value) {
                  saveFormChanges();
                },
                attribute: 'description',
                decoration: InputDecoration(labelText: 'Description'),
                initialValue: intervention.description),
          ],
        ));
  }

  Widget _buildShowMetaData() {
    return ListTile(
      title: Text(intervention.name.isEmpty ? 'Name' : intervention.name),
      subtitle: Text(intervention.description.isEmpty ? 'Description' : intervention.description),
    );
  }

  void saveFormChanges() {
    _editFormKey.currentState.save();
    if (_editFormKey.currentState.validate()) {
      setState(() {
        intervention.name = _editFormKey.currentState.value['name'];
        intervention.description = _editFormKey.currentState.value['description'];
      });
      print('saved');
    } else {
      print('validation failed');
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
