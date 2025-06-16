import 'package:reactive_forms/reactive_forms.dart';
import 'package:studyu_core/core.dart';
import 'package:studyu_designer_v2/features/design/shared/questionnaire/question/question_conditional_row_form_controller.dart';

abstract class IConditionalQuestionProperties {
  String get currentQuestionId;
  FormControl<LogicType> get logicTypeControl;
  FormArray<ConditionRowFormViewModel> get conditionsArray;

  void addCondition(
      {required List<Question> allQuestions, Expression? initialExpression});
  void removeCondition(int index);
}
