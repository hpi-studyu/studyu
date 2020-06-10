import 'package:parse_server_sdk/parse_server_sdk.dart';

import 'eligibility/eligibility_criterion.dart';
import 'interventions/intervention_set.dart';
import 'questionnaire/questionnaire.dart';

class StudyDetails extends ParseObject implements ParseCloneable {
  static const _keyTableName = 'StudyDetails';
  StudyDetails() : super(_keyTableName);
  StudyDetails.clone() : this();

  @override
  StudyDetails clone(Map<String, dynamic> map) => StudyDetails.clone()..fromJson(map);

  static const keyQuestionnaire = 'questionnaire';
  Questionnaire get questionnaire => Questionnaire.fromJson(get<List<dynamic>>(keyQuestionnaire));
  set questionnaire(Questionnaire questionnaire) => set<List<dynamic>>(keyQuestionnaire, questionnaire.toJson());

  static const keyEligibility = 'eligibilityCriteria';
  List<EligibilityCriterion> get eligibility =>
      get<List<dynamic>>(keyEligibility)?.map((e) => EligibilityCriterion.fromJson(e))?.toList() ?? [];
  set eligibility(List<EligibilityCriterion> eligibility) =>
      set<List<dynamic>>(keyEligibility, eligibility.map((e) => e.toJson()).toList());

  static const keyInterventionSet = 'interventionSet';
  InverventionSet get interventionSet => InverventionSet.fromJson(get<Map<String, dynamic>>(keyInterventionSet));
  set interventionSet(InverventionSet interventionSet) => set<Map<String, dynamic>>(keyInterventionSet, interventionSet.toJson());

  static const keyObservations = 'observations';
}
