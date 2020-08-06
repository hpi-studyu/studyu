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
  final GlobalKey<FormBuilderState> _editFormKey = GlobalKey<FormBuilderState>();

  void _addCheckMarkTask() {
    setState(() {
      final task = CheckmarkTask()
        ..id = Uuid().v4()
        ..title = ''
        ..schedule = [];
      widget.intervention.tasks.add(task);
    });
    print(widget.intervention.tasks);
  }

  void _removeTask(taskIndex) {
    setState(() {
      widget.intervention.tasks.removeAt(taskIndex);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Card(
          margin: EdgeInsets.all(10.0),
          child: Column(children: [
            ListTile(
                title: Text('Intervention'),
                trailing: FlatButton(onPressed: widget.remove, child: const Text('Delete'))),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(children: [
                FormBuilder(
                    key: _editFormKey,
                    autovalidate: true,
                    // readonly: true,
                    child: Column(
                      children: <Widget>[
                        FormBuilderTextField(
                            onChanged: (value) {
                              saveFormChanges();
                            },
                            name: 'name',
                            maxLength: 40,
                            decoration: InputDecoration(labelText: 'Name'),
                            initialValue: widget.intervention.name),
                        FormBuilderTextField(
                            onChanged: (value) {
                              saveFormChanges();
                            },
                            name: 'description',
                            decoration: InputDecoration(labelText: 'Description'),
                            initialValue: widget.intervention.description),
                      ],
                    )),
                ListView.builder(
                    physics: const NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    itemCount: widget.intervention.tasks.length,
                    itemBuilder: (buildContext, index) {
                      return TaskCard(
                          key: UniqueKey(), task: widget.intervention.tasks[index], remove: () => _removeTask(index));
                    }),
                RaisedButton.icon(
                    onPressed: _addCheckMarkTask, icon: Icon(Icons.add), color: Colors.green, label: Text('Add Task')),
              ]),
            ),
          ]),
        ),
      ],
    );
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
}
