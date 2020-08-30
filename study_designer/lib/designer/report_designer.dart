import 'dart:html';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:studyou_core/models/report/report_models.dart';
import 'package:studyou_core/util/localization.dart';

import '../models/designer_state.dart';
import '../widgets/report/report_section_editor.dart';
import '../widgets/util/designer_add_button.dart';

class ReportDesigner extends StatefulWidget {
  @override
  _ReportDesignerState createState() => _ReportDesignerState();
}

class _ReportDesignerState extends State<ReportDesigner> {
  ReportSpecification _reportSpecification;

  void _addSection() {
    final section = AverageSection.designerDefault();
    setState(() {
      if (_reportSpecification.primary == null) {
        _reportSpecification.primary = section;
      } else {
        _reportSpecification.secondary.add(section);
      }
    });
  }

  void _removeSection(index) {
    setState(() {
      if (index == -1) {
        _reportSpecification.primary = null;
      } else {
        _reportSpecification.secondary.removeAt(index);
      }
    });
  }

  void _replaceSection(index, ReportSection section) {
    setState(() {
      if (index == -1) {
        _reportSpecification.primary = section;
      } else {
        _reportSpecification.secondary[index] = section;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    _reportSpecification = context.watch<DesignerState>().draftStudy.studyDetails.reportSpecification;
    return Stack(
      children: [
        Center(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: SingleChildScrollView(
              child: Column(
                children: <Widget>[
                  if (_reportSpecification.primary != null)
                    ReportSectionEditor(
                      key: UniqueKey(),
                      section: _reportSpecification.primary,
                      isPrimary: true,
                      remove: () => _removeSection(-1),
                      updateSection: (section) => _replaceSection(-1, section),
                    ),
                  ..._reportSpecification.secondary
                      .asMap()
                      .entries
                      .map((entry) => ReportSectionEditor(
                            key: UniqueKey(),
                            section: entry.value,
                            isPrimary: false,
                            remove: () => _removeSection(entry.key),
                            updateSection: (section) => _replaceSection(entry.key, section),
                          ))
                      .toList()
                ],
              ),
            ),
          ),
        ),
        DesignerAddButton(label: Text(Nof1Localizations.of(context).translate('add_section')), add: _addSection)
      ],
    );
  }
}
