import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import 'package:studyou_core/core.dart';
import 'package:studyu_designer/designer/help_wrapper.dart';
import 'package:studyu_designer/models/app_state.dart';

import '../widgets/question/questionnaire_editor.dart';
import '../widgets/util/designer_add_button.dart';

class EligibilityQuestionsDesigner extends StatefulWidget {
  @override
  _EligibilityQuestionsDesignerState createState() => _EligibilityQuestionsDesignerState();
}

class _EligibilityQuestionsDesignerState extends State<EligibilityQuestionsDesigner> {
  Questionnaire questionnaire;

  void _addQuestion() {
    setState(() {
      questionnaire.questions.add(BooleanQuestion.withId());
    });
  }

  @override
  Widget build(BuildContext context) {
    if (context.watch<AppState>().draftStudy == null) return Container();
    questionnaire = context.watch<AppState>().draftStudy.questionnaire;
    return DesignerHelpWrapper(
      helpTitle: AppLocalizations.of(context).eligibility_questions_help_title,
      helpText: AppLocalizations.of(context).eligibility_questions_help_body,
      studyPublished: context.watch<AppState>().draftStudy.published,
      child: Stack(
        children: [
          Center(
              child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: SingleChildScrollView(
                    child: QuestionnaireEditor(
                        questionnaire: questionnaire,
                        questionTypes: [BooleanQuestion.questionType, ChoiceQuestion.questionType]),
                  ))),
          DesignerAddButton(label: Text(AppLocalizations.of(context).add_question), add: _addQuestion),
        ],
      ),
    );
  }
}
