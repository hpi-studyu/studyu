import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:studyou_core/models/study_results/results/intervention_result.dart';
import 'package:studyou_core/models/study_results/results/numeric_result.dart';
import 'package:studyou_core/models/study_results/study_result.dart';
import 'package:uuid/uuid.dart';

import '../models/designer_state.dart';
import '../widgets/designer_add_button.dart';
import '../widgets/study_result/study_result_editor.dart';

class ResultsDesigner extends StatefulWidget {
  @override
  _ResultsDesignerState createState() => _ResultsDesignerState();
}

class _ResultsDesignerState extends State<ResultsDesigner> {
  List<StudyResult> _results;

  void _addResult() {
    final result = InterventionResult()..id = Uuid().v4();
    setState(() {
      _results.add(result);
    });
  }

  void _removeResult(index) {
    setState(() {
      _results.removeAt(index);
    });
  }

  void _changeQuestionType(int index, String newType) {
    final oldResult = _results[index];
    StudyResult newResult;
    if (newType == InterventionResult.studyResultType) {
      newResult = InterventionResult();
    } else if (newType == NumericResult.studyResultType) {
      newResult = NumericResult();
    }
    newResult.id = Uuid().v4();
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
                          changeResultType: (newType) => _changeQuestionType(entry.key, newType)))
                      .toList()
                ],
              ),
            ),
          ),
        ),
        DesignerAddButton(label: Text('Add Result'), add: _addResult),
      ],
    );
  }
}
