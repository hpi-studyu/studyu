import 'package:reactive_forms/reactive_forms.dart';
import 'package:studyu_core/core.dart';

abstract class IConditionalQuestionProperties {
  String get currentQuestionId;
  FormControl<LogicType> get logicTypeControl;
  FormArray get conditionsArray;

  void addCondition(
      {required List<Question> allQuestions, Expression? initialExpression});
  void removeCondition(int index);
}
