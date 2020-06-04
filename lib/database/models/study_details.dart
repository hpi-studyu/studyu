import 'package:parse_server_sdk/parse_server_sdk.dart';

import 'expressions/expression.dart';
import 'intervention.dart';
import 'questionnaire/questionnaire.dart';

class StudyDetails extends ParseObject implements ParseCloneable {
  static const _keyTableName = 'StudyDetails';
  StudyDetails() : super(_keyTableName);
  StudyDetails.clone() : this();

  @override
  StudyDetails clone(Map<String, dynamic> map) => StudyDetails.clone()..fromJson(map);

  Questionnaire get questionnaire => Questionnaire.fromJson(get<List<dynamic>>(keyQuestionnaire));
  set questionnaire(Questionnaire questionnaire) => set<List<dynamic>>(keyQuestionnaire, questionnaire.toJson());

  static const keyQuestionnaire = 'questionnaire';
  List<Expression> get eligibility =>
      get<List<dynamic>>(keyEligibility)?.map((e) => Expression.parseJson(e))?.toList() ?? [];

  static const keyEligibility = 'eligibilityCriteria';
  set eligibility(List<Expression> eligibility) =>
      set<List<Map<String, dynamic>>>(keyEligibility, eligibility.map((e) => e.toJson()).toList());

  static const keyInterventions = 'interventionSet';
  List<Intervention> get interventions =>
      get<List<dynamic>>(keyInterventions)?.map((e) => Intervention.fromJson(e))?.toList() ?? [];

  static const keyObservations = 'observations';
  set interventions(List<Intervention> interventions) =>
      set<List<Map<String, dynamic>>>(keyInterventions, interventions.map((e) => e.toJson()).toList());
}
