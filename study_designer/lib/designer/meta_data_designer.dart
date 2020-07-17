import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:provider/provider.dart';
import 'package:studyou_core/models/models.dart';

import '../models/desinger_state.dart';

class MetaDataDesigner extends StatefulWidget {
  @override
  _MetaDataDesignerState createState() => _MetaDataDesignerState();
}

class _MetaDataDesignerState extends State<MetaDataDesigner> {
  Study _draftStudy;

  @override
  void initState() {
    super.initState();
    _draftStudy = context.read<DesignerModel>().draftStudy;
  }

  final GlobalKey<FormBuilderState> _editFormKey = GlobalKey<FormBuilderState>();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.all(16),
      child: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            FormBuilder(
              key: _editFormKey,
              autovalidate: true,
              // readonly: true,
              child: Column(
                children: <Widget>[
                  FormBuilderTextField(
                      attribute: 'title',
                      maxLength: 40,
                      decoration: InputDecoration(labelText: 'Title'),
                      initialValue: _draftStudy.title),
                  FormBuilderTextField(
                      attribute: 'description',
                      decoration: InputDecoration(labelText: 'Description'),
                      initialValue: _draftStudy.description),
                  MaterialButton(
                    color: Theme.of(context).accentColor,
                    onPressed: () {
                      _editFormKey.currentState.save();
                      if (_editFormKey.currentState.validate()) {
                        setState(() {
                          _draftStudy
                            ..title = _editFormKey.currentState.value['title']
                            ..description = _editFormKey.currentState.value['description'];
                        });
                        print('saved');
                        // TODO: show dialog "saved"
                      } else {
                        print('validation failed');
                      }
                    },
                    child: Text(
                      'Save',
                      style: TextStyle(color: Colors.white),
                    ),
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
