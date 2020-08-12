import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:study_designer/widgets/task/questionnaire_task_editor_section.dart';
import 'package:study_designer/widgets/task/task_schedule_editor_section.dart';
import 'package:studyou_core/models/models.dart';

class TaskEditor extends StatefulWidget {
  final Task task;
  final void Function() remove;

  const TaskEditor({@required this.task, @required this.remove, Key key}) : super(key: key);

  @override
  _TaskEditorState createState() => _TaskEditorState();
}

class _TaskEditorState extends State<TaskEditor> {
  final GlobalKey<FormBuilderState> _editFormKey = GlobalKey<FormBuilderState>();

  @override
  Widget build(BuildContext context) {
    final taskBody = buildTaskBody();

    return Card(
        margin: EdgeInsets.all(10.0),
        child: Column(children: [
          ListTile(
              title: Row(
                children: [Text(widget.task.type), Text(' task')],
              ),
              trailing: FlatButton(
                onPressed: widget.remove,
                child: const Text('Delete'),
              )),
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
                        name: 'title',
                        maxLength: 40,
                        decoration: InputDecoration(labelText: 'Title'),
                        initialValue: widget.task.title),
                  ],
                ),
              ),
              if (taskBody != null) taskBody,
              TaskScheduleEditorSection(
                task: widget.task,
              )
            ]),
          )
        ]));
  }

  Widget buildTaskBody() {
    switch (widget.task.runtimeType) {
      case QuestionnaireTask:
        return QuestionnaireTaskEditorSection(
          task: widget.task,
        );
      default:
        return null;
    }
  }

  void saveFormChanges() {
    _editFormKey.currentState.save();
    if (_editFormKey.currentState.validate()) {
      setState(() {
        widget.task.title = _editFormKey.currentState.value['title'];
//        task.hour = int.parse(_editFormKey.currentState.value['hour']);
//        task.minute = int.parse(_editFormKey.currentState.value['minute']);
      });
    }
  }
}
