import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:study_designer/widgets/eligibility/eligibility_criterion_editor.dart';
import 'package:studyou_core/models/models.dart';
import 'package:uuid/uuid.dart';

import '../models/designer_state.dart';
import '../widgets/designer_add_button.dart';

class EligibilityDesigner extends StatefulWidget {
  @override
  _EligibilityDesignerState createState() => _EligibilityDesignerState();
}

class _EligibilityDesignerState extends State<EligibilityDesigner> {
  List<EligibilityCriterion> _eligibility;

  void _addCriterion() {
    final criterion = EligibilityCriterion()..id = Uuid().v4();
    setState(() {
      _eligibility.add(criterion);
    });
  }

  void _removeEligibilityCriterion(index) {
    setState(() {
      _eligibility.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    _eligibility = context.watch<DesignerState>().draftStudy.studyDetails.eligibility;
    return Stack(
      children: [
        Center(
            child: Padding(
                padding: const EdgeInsets.all(16),
                child: SingleChildScrollView(
                    child: Column(children: <Widget>[
                  ..._eligibility.asMap().entries.map((entry) => EligibilityCriterionEditor(
                      key: UniqueKey(),
                      eligibilityCriterion: entry.value,
                      remove: () => _removeEligibilityCriterion(entry.key)))
                ])))),
        DesignerAddButton(label: Text('Add Criterion'), add: _addCriterion),
      ],
    );
  }
}
