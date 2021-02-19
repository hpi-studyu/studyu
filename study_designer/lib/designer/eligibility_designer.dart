import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import 'package:studyou_core/models/models.dart';
import 'package:studyu_designer/designer/help_wrapper.dart';
import 'package:studyu_designer/models/app_state.dart';

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
    if (context.watch<AppState>().draftStudy == null) return Container();
    _eligibility = context.watch<AppState>().draftStudy.eligibility;
    _questions = context.watch<AppState>().draftStudy.questionnaire.questions;
    return DesignerHelpWrapper(
      helpTitle: AppLocalizations.of(context).eligibility_criteria_help_title,
      helpText: AppLocalizations.of(context).eligibility_criteria_help_body,
      studyPublished: context.watch<AppState>().draftStudy.published,
      child: _questions.isNotEmpty
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
                DesignerAddButton(label: Text(AppLocalizations.of(context).add_criterion), add: _addCriterion),
              ],
            )
          : Center(child: Text(AppLocalizations.of(context).no_questions_yet)),
    );
  }
}
