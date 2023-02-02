import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import 'package:studyu_core/core.dart';
import 'package:studyu_designer/designer/help_wrapper.dart';
import 'package:studyu_designer/models/app_state.dart';

import '../widgets/study_result/study_result_editor.dart';
import '../widgets/util/designer_add_button.dart';

class ResultsDesigner extends StatefulWidget {
  @override
  _ResultsDesignerState createState() => _ResultsDesignerState();
}

class _ResultsDesignerState extends State<ResultsDesigner> {
  List<StudyResult> _results;

  void _addResult() {
    setState(() {
      _results.add(InterventionResult.withId());
    });
  }

  void _removeResult(int index) {
    setState(() {
      _results.removeAt(index);
    });
  }

  void _changeResultsType(int index, String newType) {
    StudyResult newResult;
    if (newType == InterventionResult.studyResultType) {
      newResult = InterventionResult.withId();
    } else if (newType == NumericResult.studyResultType) {
      newResult = NumericResult.withId();
    }
    setState(() {
      _results[index] = newResult;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (context.watch<AppState>().draftStudy == null) return Container();
    _results = context.watch<AppState>().draftStudy.results;

    return DesignerHelpWrapper(
      helpTitle: AppLocalizations.of(context).results_help_title,
      helpText: AppLocalizations.of(context).results_help_body,
      studyPublished: context.watch<AppState>().draftStudy.published,
      child: Stack(
        children: [
          Center(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: SingleChildScrollView(
                child: Column(
                  children: <Widget>[
                    ..._results.asMap().entries.map(
                          (entry) => StudyResultEditor(
                            key: UniqueKey(),
                            result: entry.value,
                            remove: () => _removeResult(entry.key),
                            changeResultType: (newType) => _changeResultsType(entry.key, newType),
                          ),
                        ),
                    const SizedBox(height: 200)
                  ],
                ),
              ),
            ),
          ),
          DesignerAddButton(label: Text(AppLocalizations.of(context).add_result), add: _addResult),
        ],
      ),
    );
  }
}
