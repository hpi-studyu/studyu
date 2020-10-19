import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter_iconpicker/flutter_iconpicker.dart';
import 'package:material_design_icons_flutter/icon_map.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:provider/provider.dart';
import 'package:studyou_core/models/models.dart';
import 'package:studyou_core/util/localization.dart';

import '../models/designer_state.dart';

class MetaDataDesigner extends StatefulWidget {
  @override
  _MetaDataDesignerState createState() => _MetaDataDesignerState();
}

class _MetaDataDesignerState extends State<MetaDataDesigner> {
  StudyBase _draftStudy;
  final GlobalKey<FormBuilderState> _editFormKey = GlobalKey<FormBuilderState>();

  @override
  void initState() {
    super.initState();
    _draftStudy = context.read<DesignerState>().draftStudy;
  }

  Future<void> _pickIcon() async {
    final icon = await FlutterIconPicker.showIconPicker(context,
        iconPackMode: IconPack.custom,
        customIconPack: {for (var key in MdiIcons.getIconsName()) key: MdiIcons.fromString(key)});

    final iconName = iconMap.keys.firstWhere((k) => iconMap[k] == icon.codePoint, orElse: () => null);
    setState(() {
      _draftStudy.iconName = iconName;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            FormBuilder(
              key: _editFormKey,
              autovalidateMode: AutovalidateMode.onUserInteraction,
              // readonly: true,
              child: Column(
                children: <Widget>[
                  FormBuilderTextField(
                      onChanged: _saveFormChanges,
                      name: 'title',
                      maxLength: 40,
                      decoration: InputDecoration(labelText: Nof1Localizations.of(context).translate('title')),
                      initialValue: _draftStudy.title),
                  FormBuilderTextField(
                      onChanged: _saveFormChanges,
                      name: 'description',
                      decoration: InputDecoration(labelText: Nof1Localizations.of(context).translate('description')),
                      initialValue: _draftStudy.description),
                  Row(children: [
                    Expanded(
                      child: FlatButton(
                        onPressed: _pickIcon,
                        child: Text(Nof1Localizations.of(context).translate('choose_icon')),
                      ),
                    ),
                    if (MdiIcons.fromString(_draftStudy.iconName) != null)
                      Expanded(child: Icon(MdiIcons.fromString(_draftStudy.iconName)))
                  ]),
                  FormBuilderTextField(
                      onChanged: _saveFormChanges,
                      name: 'organization',
                      maxLength: 40,
                      decoration: InputDecoration(labelText: Nof1Localizations.of(context).translate('organization')),
                      initialValue: _draftStudy.organization),
                  FormBuilderTextField(
                      onChanged: _saveFormChanges,
                      name: 'researchers',
                      maxLength: 40,
                      decoration: InputDecoration(labelText: Nof1Localizations.of(context).translate('researchers')),
                      initialValue: _draftStudy.researchers),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _saveFormChanges(value) {
    _editFormKey.currentState.save();
    if (_editFormKey.currentState.validate()) {
      setState(() {
        _draftStudy
          ..organization = _editFormKey.currentState.value['organization']
          ..researchers = _editFormKey.currentState.value['researchers']
          ..title = _editFormKey.currentState.value['title']
          ..description = _editFormKey.currentState.value['description'];
      });
    }
  }
}
