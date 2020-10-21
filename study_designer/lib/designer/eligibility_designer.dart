import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:studyou_core/models/models.dart';
import 'package:studyou_core/util/localization.dart';

import '../models/designer_state.dart';
import '../widgets/eligibility/eligibility_criterion_editor.dart';
import '../widgets/util/designer_add_button.dart';

class EligibilityCriteriaDesigner extends StatefulWidget {
  @override
  _EligibilityCriteriaDesignerState createState() => _EligibilityCriteriaDesignerState();
}

class _EligibilityCriteriaDesignerState extends State<EligibilityCriteriaDesigner> {
  List<EligibilityCriterion> _eligibility;
  List<Question> _questions;

  void _addCriterion() {
    setState(() {
      _eligibility.add(EligibilityCriterion.designerDefault());
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
    _questions = context.watch<DesignerState>().draftStudy.studyDetails.questionnaire.questions;
    return _questions.isNotEmpty
        ? Stack(
            children: [
              Center(
                  child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: SingleChildScrollView(
                          child: Column(children: <Widget>[
                        ..._eligibility.asMap().entries.map((entry) => EligibilityCriterionEditor(
                            key: UniqueKey(),
                            eligibilityCriterion: entry.value,
                            questions: _questions,
                            remove: () => _removeEligibilityCriterion(entry.key))),
                        SizedBox(height: 200)
                      ])))),
              DesignerAddButton(
                  label: Text(Nof1Localizations.of(context).translate('add_criterion')), add: _addCriterion),
            ],
          )
        : Center(child: Text(Nof1Localizations.of(context).translate('no_questions_yet')));
  }
}
