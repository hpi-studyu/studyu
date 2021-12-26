import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_iconpicker/flutter_iconpicker.dart';
import 'package:material_design_icons_flutter/icon_map.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:studyu_core/core.dart';
import 'package:studyu_designer/widgets/buttons.dart';

import '../task/task_editor.dart';
import '../util/helper.dart';

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
    final icon = await FlutterIconPicker.showIconPicker(
      context,
      iconPackModes: [IconPack.custom],
      customIconPack: {for (var key in MdiIcons.getIconsName()) key: MdiIcons.fromString(key)},
    );

    final iconName = iconMap.keys.firstWhere((k) => iconMap[k] == icon.codePoint, orElse: () => null);
    setState(() {
      widget.intervention.icon = iconName;
    });
  }

  void _addCheckMarkTask() {
    setState(() {
      widget.intervention.tasks.add(CheckmarkTask.withId());
    });
  }

  void _removeTask(int taskIndex) {
    setState(() {
      widget.intervention.tasks.removeAt(taskIndex);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Card(
          margin: const EdgeInsets.all(10),
          child: Column(
            children: [
              ListTile(
                title: Text(AppLocalizations.of(context).intervention),
                trailing: DeleteButton(onPressed: widget.remove),
              ),
              Padding(
                padding: const EdgeInsets.all(8),
                child: Column(
                  children: [
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
                            name: 'name',
                            maxLength: 40,
                            decoration: InputDecoration(labelText: AppLocalizations.of(context).name),
                            initialValue: widget.intervention.name,
                          ),
                          Row(
                            children: [
                              Expanded(
                                child: TextButton(
                                  onPressed: _pickIcon,
                                  child: Text(AppLocalizations.of(context).choose_icon),
                                ),
                              ),
                              if (MdiIcons.fromString(widget.intervention.icon) != null)
                                Expanded(child: Icon(MdiIcons.fromString(widget.intervention.icon)))
                            ],
                          ),
                          FormBuilderTextField(
                            onChanged: (value) {
                              saveFormChanges();
                            },
                            name: 'description',
                            decoration: InputDecoration(labelText: AppLocalizations.of(context).description),
                            initialValue: widget.intervention.description,
                          ),
                        ],
                      ),
                    ),
                    ListView.builder(
                      physics: const NeverScrollableScrollPhysics(),
                      shrinkWrap: true,
                      itemCount: widget.intervention.tasks.length,
                      itemBuilder: (buildContext, index) {
                        return TaskEditor(
                          key: UniqueKey(),
                          task: widget.intervention.tasks[index],
                          remove: () => _removeTask(index),
                        );
                      },
                    ),
                    ElevatedButton.icon(
                      onPressed: _addCheckMarkTask,
                      icon: const Icon(Icons.add),
                      style: ElevatedButton.styleFrom(primary: Colors.green),
                      label: Text(AppLocalizations.of(context).add_task),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void saveFormChanges() {
    _editFormKey.currentState.save();
    if (_editFormKey.currentState.validate()) {
      setState(() {
        widget.intervention.name = _editFormKey.currentState.value['name'] as String;
        widget.intervention.id = (_editFormKey.currentState.value['name'] as String).toId();
        widget.intervention.description = _editFormKey.currentState.value['description'] as String;
      });
    }
  }
}
