import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter_iconpicker/flutter_iconpicker.dart';
import 'package:material_design_icons_flutter/icon_map.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:studyou_core/models/interventions/intervention.dart';
import 'package:studyou_core/models/interventions/interventions.dart';

import '../task/task_editor.dart';

class InterventionEditor extends StatefulWidget {
  final Intervention intervention;
  final void Function() remove;

  const InterventionEditor({@required this.intervention, @required this.remove, Key key}) : super(key: key);

  @override
  _InterventionEditorState createState() => _InterventionEditorState();
}

class _InterventionEditorState extends State<InterventionEditor> {
  final GlobalKey<FormBuilderState> _editFormKey = GlobalKey<FormBuilderState>();

  Future<void> _pickIcon() async {
    final icon = await FlutterIconPicker.showIconPicker(context,
        iconPackMode: IconPack.custom,
        customIconPack: {for (var key in MdiIcons.getIconsName()) key: MdiIcons.fromString(key)});

    final iconName = iconMap.keys.firstWhere((k) => iconMap[k] == icon.codePoint, orElse: () => null);
    setState(() {
      widget.intervention.icon = iconName;
    });
  }

  void _addCheckMarkTask() {
    setState(() {
      widget.intervention.tasks.add(CheckmarkTask.designer());
    });
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
          margin: EdgeInsets.all(10),
          child: Column(children: [
            ListTile(
                title: Text('Intervention'),
                trailing: FlatButton(onPressed: widget.remove, child: const Text('Delete'))),
            Padding(
              padding: const EdgeInsets.all(8),
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
                        Row(children: [
                          Expanded(
                            child: FlatButton(
                              onPressed: _pickIcon,
                              child: Text('Choose Icon'),
                            ),
                          ),
                          if (MdiIcons.fromString(widget.intervention.icon) != null)
                            Expanded(child: Icon(MdiIcons.fromString(widget.intervention.icon)))
                        ]),
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
                      return TaskEditor(
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
