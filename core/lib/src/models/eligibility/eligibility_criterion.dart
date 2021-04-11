import 'package:json_annotation/json_annotation.dart';
import 'package:uuid/uuid.dart';

import '../expressions/expression.dart';
import '../expressions/types/boolean_expression.dart';
import '../questionnaire/questionnaire_state.dart';

part 'eligibility_criterion.g.dart';

@JsonSerializable()
class EligibilityCriterion {
  String id;
  String reason;
  Expression condition;

  EligibilityCriterion();

  EligibilityCriterion.designerDefault()
      : id = Uuid().v4(),
        condition = BooleanExpression();

  factory EligibilityCriterion.fromJson(Map<String, dynamic> data) => _$EligibilityCriterionFromJson(data);
  Map<String, dynamic> toJson() => _$EligibilityCriterionToJson(this);

  bool isSatisfied(QuestionnaireState qs) => condition.evaluate(qs) == true;
  bool isViolated(QuestionnaireState qs) => condition.evaluate(qs) == false;
}
