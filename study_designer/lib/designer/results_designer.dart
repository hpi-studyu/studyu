import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:studyou_core/models/study_results/results/intervention_result.dart';
import 'package:studyou_core/models/study_results/results/numeric_result.dart';
import 'package:studyou_core/models/study_results/study_result.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../models/designer_state.dart';
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
      _results.add(InterventionResult.designerDefault());
    });
  }

  void _removeResult(index) {
    setState(() {
      _results.removeAt(index);
    });
  }

  void _changeResultsType(int index, String newType) {
    StudyResult newResult;
    if (newType == InterventionResult.studyResultType) {
      newResult = InterventionResult.designerDefault();
    } else if (newType == NumericResult.studyResultType) {
      newResult = NumericResult.designerDefault();
    }
    setState(() {
      _results[index] = newResult;
    });
  }

  @override
  Widget build(BuildContext context) {
    _results = context.watch<DesignerState>().draftStudy.studyDetails.results;

    return Stack(
      children: [
        Center(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: SingleChildScrollView(
              child: Column(
                children: <Widget>[
                  ..._results
                      .asMap()
                      .entries
                      .map((entry) => StudyResultEditor(
                          key: UniqueKey(),
                          result: entry.value,
                          remove: () => _removeResult(entry.key),
                          changeResultType: (newType) => _changeResultsType(entry.key, newType)))
                      .toList(),
                  SizedBox(height: 200)
                ],
              ),
            ),
          ),
        ),
        DesignerAddButton(label: Text(AppLocalizations.of(context).add_result), add: _addResult),
      ],
    );
  }
}
