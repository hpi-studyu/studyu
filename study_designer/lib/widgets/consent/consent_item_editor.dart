import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_iconpicker/flutter_iconpicker.dart';
import 'package:material_design_icons_flutter/icon_map.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:studyou_core/core.dart';

class ConsentItemEditor extends StatefulWidget {
  final ConsentItem consentItem;
  final void Function() remove;

  const ConsentItemEditor({@required this.consentItem, @required this.remove, Key key}) : super(key: key);

  @override
  _ConsentItemEditorState createState() => _ConsentItemEditorState();
}

class _ConsentItemEditorState extends State<ConsentItemEditor> {
  final GlobalKey<FormBuilderState> _editFormKey = GlobalKey<FormBuilderState>();

  Future<void> _pickIcon() async {
    final icon = await FlutterIconPicker.showIconPicker(context,
        iconPackMode: IconPack.custom,
        customIconPack: {for (var key in MdiIcons.getIconsName()) key: MdiIcons.fromString(key)});

    final iconName = iconMap.keys.firstWhere((k) => iconMap[k] == icon.codePoint, orElse: () => null);
    setState(() {
      widget.consentItem.iconName = iconName;
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
                title: Text(AppLocalizations.of(context).consent_item),
                trailing: TextButton(onPressed: widget.remove, child: Text(AppLocalizations.of(context).delete))),
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
                            maxLength: 40,
                            decoration: InputDecoration(labelText: AppLocalizations.of(context).title),
                            initialValue: widget.consentItem.title),
                        Row(children: [
                          Expanded(
                            child: TextButton(
                              onPressed: _pickIcon,
                              child: Text(AppLocalizations.of(context).choose_icon),
                            ),
                          ),
                          if (MdiIcons.fromString(widget.consentItem.iconName) != null)
                            Expanded(child: Icon(MdiIcons.fromString(widget.consentItem.iconName)))
                        ]),
                        FormBuilderTextField(
                            onChanged: (value) {
                              saveFormChanges();
                            },
                            name: 'description',
                            decoration: InputDecoration(labelText: AppLocalizations.of(context).description),
                            initialValue: widget.consentItem.description),
                      ],
                    )),
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
        widget.consentItem.title = _editFormKey.currentState.value['title'] as String;
        widget.consentItem.description = _editFormKey.currentState.value['description'] as String;
      });
    }
  }
}
