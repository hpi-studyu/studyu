import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:studyu_core/core.dart';
import 'package:studyu_designer/widgets/buttons.dart';

import '../util/helper.dart';
import 'questionnaire_task_editor_section.dart';
import 'task_schedule_editor_section.dart';

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
        margin: EdgeInsets.all(10),
        child: Column(children: [
          ListTile(
            title: Row(
              children: [Text('${widget.task.type[0].toUpperCase()}${widget.task.type.substring(1)}'), Text(' Task')],
            ),
            trailing: DeleteButton(
              onPressed: widget.remove,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8),
            child: Column(children: [
              FormBuilder(
                key: _editFormKey,
                autovalidateMode: AutovalidateMode.onUserInteraction,
                // readonly: true,
                child: Column(
                  children: <Widget>[
                    FormBuilderTextField(
                        onChanged: (value) {
                          saveFormChanges();
                        },
                        name: 'title',
                        decoration: InputDecoration(labelText: AppLocalizations.of(context).title),
                        initialValue: widget.task.title),
                    FormBuilderTextField(
                        onChanged: (value) {
                          saveFormChanges();
                        },
                        name: 'header',
                        decoration: InputDecoration(labelText: 'Header'),
                        initialValue: widget.task.header),
                    FormBuilderTextField(
                        onChanged: (value) {
                          saveFormChanges();
                        },
                        name: 'footer',
                        decoration: InputDecoration(labelText: 'Footer'),
                        initialValue: widget.task.footer),
                  ],
                ),
              ),
              if (taskBody != null) taskBody,
              Divider(),
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
          task: widget.task as QuestionnaireTask,
        );
      default:
        return null;
    }
  }

  void saveFormChanges() {
    _editFormKey.currentState.save();
    if (_editFormKey.currentState.validate()) {
      setState(() {
        widget.task.title = _editFormKey.currentState.value['title'] as String;
        widget.task.id = (_editFormKey.currentState.value['title'] as String).toId();
        widget.task.header = _editFormKey.currentState.value['header'] as String;
        widget.task.footer = _editFormKey.currentState.value['footer'] as String;
//        task.hour = int.parse(_editFormKey.currentState.value['hour']);
//        task.minute = int.parse(_editFormKey.currentState.value['minute']);
      });
    }
  }
}
