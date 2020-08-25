import 'package:parse_server_sdk/parse_server_sdk.dart';

import '../models.dart';

class ParseStudyDetails extends ParseObject implements ParseCloneable, StudyDetailsBase {
  static const _keyTableName = 'StudyDetails';

  ParseStudyDetails() : super(_keyTableName);

  ParseStudyDetails.clone() : this();

  @override
  ParseStudyDetails clone(Map<String, dynamic> map) => ParseStudyDetails.clone()..fromJson(map);

  factory ParseStudyDetails.fromBase(StudyDetailsBase studyDetails) {
    return ParseStudyDetails()
      ..questionnaire = studyDetails.questionnaire
      ..eligibility = studyDetails.eligibility
      ..consent = studyDetails.consent
      ..interventionSet = studyDetails.interventionSet
      ..observations = studyDetails.observations
      ..schedule = studyDetails.schedule
      ..reportSpecification = studyDetails.reportSpecification;
  }

  static const keyQuestionnaire = 'questionnaire';
  Questionnaire get questionnaire => Questionnaire.fromJson(get<List<dynamic>>(keyQuestionnaire));
  set questionnaire(Questionnaire questionnaire) => set<List<dynamic>>(keyQuestionnaire, questionnaire.toJson());

  static const keyEligibility = 'eligibilityCriteria';
  List<EligibilityCriterion> get eligibility =>
      get<List<dynamic>>(keyEligibility)?.map((e) => EligibilityCriterion.fromJson(e))?.toList() ?? [];
  set eligibility(List<EligibilityCriterion> eligibility) =>
      set<List<dynamic>>(keyEligibility, eligibility.map((e) => e.toJson()).toList());

  static const keyConsent = 'consent';
  List<ConsentItem> get consent =>
      get<List<dynamic>>(keyConsent, defaultValue: []).map((e) => ConsentItem.fromJson(e)).toList();
  set consent(List<ConsentItem> consent) => set<List<dynamic>>(keyConsent, consent.map((e) => e.toJson()).toList());

  static const keyInterventionSet = 'interventionSet';
  InterventionSet get interventionSet => InterventionSet.fromJson(get<Map<String, dynamic>>(keyInterventionSet));
  set interventionSet(InterventionSet interventionSet) =>
      set<Map<String, dynamic>>(keyInterventionSet, interventionSet.toJson());

  static const keyObservations = 'observations';
  List<Observation> get observations =>
      get<List<dynamic>>(keyObservations)?.map((e) => Observation.fromJson(e))?.toList() ?? [];
  set observations(List<Observation> observations) =>
      set<List<dynamic>>(keyObservations, observations.map((e) => e.toJson()).toList());

  static const keySchedule = 'schedule';
  StudySchedule get schedule => StudySchedule.fromJson(get<Map<String, dynamic>>(keySchedule));
  set schedule(StudySchedule schedule) => set<Map<String, dynamic>>(keySchedule, schedule.toJson());

  static const keyReportSpecification = 'report_specification';
  ReportSpecification get reportSpecification =>
      ReportSpecification.fromJson(get<Map<String, dynamic>>(keyReportSpecification));
  set reportSpecification(ReportSpecification reportSpecification) =>
      set<Map<String, dynamic>>(keyReportSpecification, reportSpecification.toJson());

  static const keyResults = 'results';
  List<StudyResult> get results => get<List<dynamic>>(keyResults)?.map((e) => StudyResult.fromJson(e))?.toList() ?? [];
  set results(List<StudyResult> results) => set<List<dynamic>>(keyResults, results.map((e) => e.toJson()).toList());
}
