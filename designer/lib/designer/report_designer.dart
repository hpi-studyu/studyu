import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import 'package:studyu_core/core.dart';
import 'package:studyu_designer/designer/help_wrapper.dart';
import 'package:studyu_designer/models/app_state.dart';

import '../widgets/report/report_section_editor.dart';
import '../widgets/util/designer_add_button.dart';

class ReportDesigner extends StatefulWidget {
  @override
  _ReportDesignerState createState() => _ReportDesignerState();
}

class _ReportDesignerState extends State<ReportDesigner> {
  ReportSpecification _reportSpecification;

  void _addSection() {
    final section = AverageSection.withId();
    setState(() {
      if (_reportSpecification.primary == null) {
        _reportSpecification.primary = section;
      } else {
        _reportSpecification.secondary.add(section);
      }
    });
  }

  void _removeSection(int index) {
    setState(() {
      if (index == -1) {
        _reportSpecification.primary = null;
      } else {
        _reportSpecification.secondary.removeAt(index);
      }
    });
  }

  void _replaceSection(int index, ReportSection section) {
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
    if (context.watch<AppState>().draftStudy == null) return Container();
    _reportSpecification = context.watch<AppState>().draftStudy.reportSpecification;
    return DesignerHelpWrapper(
      helpTitle: AppLocalizations.of(context).report_help_title,
      helpText: AppLocalizations.of(context).report_help_body,
      studyPublished: context.watch<AppState>().draftStudy.published,
      child: Stack(
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
                    ..._reportSpecification.secondary.asMap().entries.map(
                          (entry) => ReportSectionEditor(
                            key: UniqueKey(),
                            section: entry.value,
                            isPrimary: false,
                            remove: () => _removeSection(entry.key),
                            updateSection: (section) => _replaceSection(entry.key, section),
                          ),
                        ),
                    const SizedBox(height: 200)
                  ],
                ),
              ),
            ),
          ),
          DesignerAddButton(label: Text(AppLocalizations.of(context).add_section), add: _addSection)
        ],
      ),
    );
  }
}
