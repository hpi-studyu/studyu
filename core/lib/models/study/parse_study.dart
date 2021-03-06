import 'package:parse_server_sdk_flutter/parse_server_sdk.dart';
import 'package:studyou_core/models/study/contact.dart';

import '../models.dart';

class ParseStudy extends ParseObject implements ParseCloneable, StudyBase {
  static const _keyTableName = 'Study';

  ParseStudy() : super(_keyTableName);

  ParseStudy.clone() : this();

  @override
  ParseStudy clone(Map<String, dynamic> map) => ParseStudy.clone()..fromJson(map);

  factory ParseStudy.fromBase(StudyBase study) {
    return ParseStudy()
      ..id = study.id
      ..contact = study.contact
      ..title = study.title
      ..description = study.description
      ..iconName = study.iconName
      ..published = study.published
      ..interventionSet = study.interventionSet
      ..questionnaire = study.questionnaire
      ..eligibility = study.eligibility
      ..observations = study.observations
      ..schedule = study.schedule
      ..consent = study.consent
      ..reportSpecification = study.reportSpecification
      ..results = study.results;
  }

  static const keyId = 'study_id';
  @override
  String get id => get<String>(keyId);
  @override
  set id(String id) => set<String>(keyId, id);

  static const keyTitle = 'title';
  @override
  String get title => get<String>(keyTitle);
  @override
  set title(String title) => set<String>(keyTitle, title);

  static const keyContact = 'contact';
  @override
  Contact get contact => Contact.fromJson(get<Map<String, dynamic>>(keyContact));
  @override
  set contact(Contact contact) => set<Map<String, dynamic>>(keyContact, contact.toJson());

  static const keyDescription = 'description';
  @override
  String get description => get<String>(keyDescription);
  @override
  set description(String description) => set<String>(keyDescription, description);

  static const keyIconName = 'icon_name';
  @override
  String get iconName => get<String>(keyIconName);
  @override
  set iconName(String iconName) => set<String>(keyIconName, iconName);

  static const keyPublished = 'published';
  @override
  bool get published => get<bool>(keyPublished);
  @override
  set published(bool published) => set<bool>(keyPublished, published);

  static const keyQuestionnaire = 'questionnaire';
  @override
  Questionnaire get questionnaire => Questionnaire.fromJson(get<List<dynamic>>(keyQuestionnaire));
  @override
  set questionnaire(Questionnaire questionnaire) => set<List<dynamic>>(keyQuestionnaire, questionnaire.toJson());

  static const keyEligibility = 'eligibilityCriteria';
  @override
  List<EligibilityCriterion> get eligibility =>
      get<List<dynamic>>(keyEligibility)?.map((e) => EligibilityCriterion.fromJson(e))?.toList() ?? [];
  @override
  set eligibility(List<EligibilityCriterion> eligibility) =>
      set<List<dynamic>>(keyEligibility, eligibility.map((e) => e.toJson()).toList());

  static const keyConsent = 'consent';
  @override
  List<ConsentItem> get consent =>
      get<List<dynamic>>(keyConsent, defaultValue: []).map((e) => ConsentItem.fromJson(e)).toList();
  @override
  set consent(List<ConsentItem> consent) => set<List<dynamic>>(keyConsent, consent.map((e) => e.toJson()).toList());

  static const keyInterventionSet = 'interventionSet';
  @override
  InterventionSet get interventionSet => InterventionSet.fromJson(get<Map<String, dynamic>>(keyInterventionSet));
  @override
  set interventionSet(InterventionSet interventionSet) =>
      set<Map<String, dynamic>>(keyInterventionSet, interventionSet.toJson());

  static const keyObservations = 'observations';
  @override
  List<Observation> get observations =>
      get<List<dynamic>>(keyObservations)?.map((e) => Observation.fromJson(e))?.toList() ?? [];
  @override
  set observations(List<Observation> observations) =>
      set<List<dynamic>>(keyObservations, observations.map((e) => e.toJson()).toList());

  static const keySchedule = 'schedule';
  @override
  StudySchedule get schedule => StudySchedule.fromJson(get<Map<String, dynamic>>(keySchedule));
  @override
  set schedule(StudySchedule schedule) => set<Map<String, dynamic>>(keySchedule, schedule.toJson());

  static const keyReportSpecification = 'report_specification';
  @override
  ReportSpecification get reportSpecification =>
      ReportSpecification.fromJson(get<Map<String, dynamic>>(keyReportSpecification));
  @override
  set reportSpecification(ReportSpecification reportSpecification) =>
      set<Map<String, dynamic>>(keyReportSpecification, reportSpecification.toJson());

  static const keyResults = 'results';
  @override
  List<StudyResult> get results => get<List<dynamic>>(keyResults)?.map((e) => StudyResult.fromJson(e))?.toList() ?? [];
  @override
  set results(List<StudyResult> results) => set<List<dynamic>>(keyResults, results.map((e) => e.toJson()).toList());

  ParseUserStudy extractUserStudy(
      String userId, List<Intervention> selectedInterventions, DateTime startDate, int firstIntervention) {
    final userStudy = ParseUserStudy()
      ..title = title
      ..description = description
      ..contact = contact
      ..iconName = iconName
      ..studyId = id
      ..userId = userId
      ..startDate = startDate
      ..interventionSet = InterventionSet(selectedInterventions)
      ..observations = observations ?? []
      ..reportSpecification = reportSpecification;
    if (schedule != null) {
      const baselineId = StudyBase.baselineID;
      var addBaseline = false;
      userStudy
        ..schedule = schedule
        ..consent = consent
        ..interventionOrder = schedule.generateWith(firstIntervention).map<String>((index) {
          if (index == null) {
            addBaseline = true;
            return baselineId;
          }
          return selectedInterventions[index].id;
        }).toList();
      if (addBaseline) {
        userStudy.interventionSet = InterventionSet([
          ...userStudy.interventionSet.interventions,
          Intervention(baselineId, 'Baseline')
            ..tasks = []
            ..icon = 'rayStart'
        ]);
      }
    } else {
      print('Study is missing schedule!');
      return null;
    }
    return userStudy;
  }
}

extension StudyQueries on ParseStudy {
  Future<ParseResponse> getPublishedStudies() async {
    final keys = ['objectId', 'study_id', 'title', 'description', 'published', 'icon_name'];
    final builder = QueryBuilder<ParseStudy>(this)
      ..whereEqualTo('published', true)
      ..keysToReturn(keys);
    return builder.query();
  }

  Future<ParseResponse> getResearcherDashboardStudies() async {
    final keys = ['objectId', 'study_id', 'title', 'description', 'published', 'icon_name', 'results', 'schedule'];
    final builder = QueryBuilder<ParseStudy>(this)..keysToReturn(keys);
    return builder.query();
  }

  Future<ParseResponse> getStudyById(String studyId) async {
    final builder = QueryBuilder<ParseStudy>(this)..whereEqualTo(ParseStudy.keyId, studyId);
    return builder.query();
  }
}
