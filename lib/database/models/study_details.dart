import 'package:parse_server_sdk/parse_server_sdk.dart';

import 'eligibility/eligibility_criterion.dart';
import 'interventions/intervention_set.dart';
import 'observations/observation.dart';
import 'questionnaire/questionnaire.dart';
import 'study_schedule/study_schedule.dart';

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
  set interventionSet(InverventionSet interventionSet) =>
      set<Map<String, dynamic>>(keyInterventionSet, interventionSet.toJson());

  static const keyObservations = 'observations';
  List<Observation> get observations =>
      get<List<dynamic>>(keyObservations)?.map((e) => Observation.fromJson(e))?.toList() ?? [];
  set observations(List<Observation> observations) =>
      set<List<dynamic>>(keyObservations, observations.map((e) => e.toJson()).toList());

  static const keySchedule = 'schedule';
  StudySchedule get schedule => StudySchedule.fromJson(get<Map<String, dynamic>>(keySchedule));
  set schedule(StudySchedule schedule) => set<Map<String, dynamic>>(keySchedule, schedule.toJson());
}
