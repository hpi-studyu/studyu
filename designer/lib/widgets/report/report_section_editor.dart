import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:studyu_core/core.dart';

import '../buttons.dart';
import '../util/helper.dart';
import 'average_section_editor_section.dart';
import 'linear_regression_section_editor_section.dart';

class ReportSectionEditor extends StatefulWidget {
  final bool isPrimary;
  final ReportSection section;
  final void Function() remove;
  final void Function(ReportSection) updateSection;

  const ReportSectionEditor({
    @required this.section,
    @required this.isPrimary,
    @required this.remove,
    @required this.updateSection,
    Key key,
  }) : super(key: key);

  @override
  _ReportSectionEditorState createState() => _ReportSectionEditorState();
}

class _ReportSectionEditorState extends State<ReportSectionEditor> {
  final GlobalKey<FormBuilderState> _editFormKey = GlobalKey<FormBuilderState>();

  void _changeSectionType(String newType) {
    ReportSection newSection;

    if (newType == LinearRegressionSection.sectionType) {
      newSection = LinearRegressionSection.withId();
    } else {
      newSection = AverageSection.withId();
    }

    newSection
      ..title = widget.section.title
      ..description = widget.section.description;

    widget.updateSection(newSection);
  }

  @override
  Widget build(BuildContext context) {
    final sectionBody = _buildSectionBody();
    return Column(
      children: [
        Card(
          margin: const EdgeInsets.all(10),
          child: Column(
            children: [
              ListTile(
                leading: widget.isPrimary ? Text('[${AppLocalizations.of(context).primary}]') : null,
                title: Row(
                  children: [
                    DropdownButton<String>(
                      value: widget.section.type,
                      onChanged: _changeSectionType,
                      items: [AverageSection.sectionType, LinearRegressionSection.sectionType]
                          .map<DropdownMenuItem<String>>((value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text('${value[0].toUpperCase()}${value.substring(1)}'),
                        );
                      }).toList(),
                    ),
                    Text(AppLocalizations.of(context).section)
                  ],
                ),
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
                            name: 'title',
                            maxLength: 40,
                            decoration: InputDecoration(labelText: AppLocalizations.of(context).title),
                            initialValue: widget.section.title,
                          ),
                          FormBuilderTextField(
                            onChanged: (value) {
                              saveFormChanges();
                            },
                            name: 'description',
                            decoration: InputDecoration(labelText: AppLocalizations.of(context).description),
                            initialValue: widget.section.description,
                          ),
                        ],
                      ),
                    ),
                    if (sectionBody != null) sectionBody
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSectionBody() {
    switch (widget.section.runtimeType) {
      case AverageSection:
        return AverageSectionEditorSection(
          section: widget.section as AverageSection,
        );
      case LinearRegressionSection:
        return LinearRegressionSectionEditorSection(
          section: widget.section as LinearRegressionSection,
        );
      default:
        return null;
    }
  }

  void saveFormChanges() {
    _editFormKey.currentState.save();
    if (_editFormKey.currentState.validate()) {
      setState(() {
        widget.section.title = _editFormKey.currentState.value['title'] as String;
        widget.section.id = (_editFormKey.currentState.value['title'] as String).toId();
        widget.section.description = _editFormKey.currentState.value['description'] as String;
      });
    }
  }
}
