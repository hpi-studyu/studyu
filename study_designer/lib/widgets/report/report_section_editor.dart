import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:study_designer/widgets/report/average_section_editor_section.dart';
import 'package:studyou_core/models/models.dart';
import 'package:studyou_core/models/report/report_section.dart';

class ReportSectionEditor extends StatefulWidget {
  final bool isPrimary;
  final ReportSection section;
  final void Function() remove;

  const ReportSectionEditor({@required this.section, @required this.isPrimary, @required this.remove, Key key})
      : super(key: key);

  @override
  _ReportSectionEditorState createState() => _ReportSectionEditorState();
}

class _ReportSectionEditorState extends State<ReportSectionEditor> {
  final GlobalKey<FormBuilderState> _editFormKey = GlobalKey<FormBuilderState>();

  @override
  Widget build(BuildContext context) {
    final sectionBody = _buildSectionBody();
    return Column(
      children: [
        Card(
          margin: EdgeInsets.all(10),
          child: Column(children: [
            ListTile(
                title: Text(
                    '${widget.isPrimary ? '[Primary]' : ''} ${widget.section.type[0].toUpperCase()}${widget.section.type.substring(1)} Section'),
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
                            name: 'title',
                            maxLength: 40,
                            decoration: InputDecoration(labelText: 'Title'),
                            initialValue: widget.section.title),
                        FormBuilderTextField(
                            onChanged: (value) {
                              saveFormChanges();
                            },
                            name: 'description',
                            decoration: InputDecoration(labelText: 'Description'),
                            initialValue: widget.section.description),
                      ],
                    )),
                if (sectionBody != null) sectionBody
              ]),
            ),
          ]),
        ),
      ],
    );
  }

  Widget _buildSectionBody() {
    switch (widget.section.runtimeType) {
      case AverageSection:
        return AverageSectionEditorSection(
          section: widget.section,
        );
      default:
        return null;
    }
  }

  void saveFormChanges() {
    _editFormKey.currentState.save();
    if (_editFormKey.currentState.validate()) {
      setState(() {
        widget.section.title = _editFormKey.currentState.value['title'];
        widget.section.description = _editFormKey.currentState.value['description'];
      });
    }
  }
}
