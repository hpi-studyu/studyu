import 'package:parse_server_sdk/parse_server_sdk.dart';

import '../models.dart';

class ParseUserStudy extends ParseObject implements ParseCloneable, UserStudyBase {
  static const _keyTableName = 'UserStudy';

  ParseUserStudy() : super(_keyTableName);

  ParseUserStudy.clone() : this();

  factory ParseUserStudy.fromBase(UserStudyBase userStudy) {
    return ParseUserStudy()
      ..organization = userStudy.organization
      ..researchers = userStudy.researchers
      ..studyId = userStudy.studyId
      ..userId = userStudy.userId
      ..title = userStudy.title
      ..description = userStudy.description
      ..iconName = userStudy.iconName
      ..startDate = userStudy.startDate
      ..schedule = userStudy.schedule
      ..interventionOrder = userStudy.interventionOrder
      ..interventionSet = userStudy.interventionSet
      ..observations = userStudy.observations
      ..consent = userStudy.consent
      ..results = userStudy.results
      ..reportSpecification = userStudy.reportSpecification;
  }

  @override
  ParseUserStudy clone(Map<String, dynamic> map) => ParseUserStudy.clone()..fromJson(map);

  static const keyStudyId = 'study_id';
  String get studyId => get<String>(keyStudyId);
  set studyId(String studyId) => set<String>(keyStudyId, studyId);

  static const keyUserId = 'user_id';
  String get userId => get<String>(keyUserId);
  set userId(String userId) => set<String>(keyUserId, userId);

  static const keyOrganization = 'organization';
  String get organization => get<String>(keyOrganization);
  set organization(String organization) => set<String>(keyOrganization, organization);

  static const keyResearchers = 'researchers';
  String get researchers => get<String>(keyResearchers);
  set researchers(String organization) => set<String>(keyResearchers, researchers);

  static const keyTitle = 'title';
  String get title => get<String>(keyTitle);
  set title(String title) => set<String>(keyTitle, title);

  static const keyDescription = 'description';
  String get description => get<String>(keyDescription);
  set description(String description) => set<String>(keyDescription, description);

  static const keyIconName = 'icon_name';
  String get iconName => get<String>(keyIconName);
  set iconName(String iconName) => set<String>(keyIconName, iconName);

  static const keyStartDate = 'start_date';
  DateTime get startDate => get<DateTime>(keyStartDate);
  set startDate(DateTime startDate) => set<DateTime>(keyStartDate, startDate);

  static const keySchedule = 'schedule';
  StudySchedule get schedule => StudySchedule.fromJson(get<Map<String, dynamic>>(keySchedule));
  set schedule(StudySchedule schedule) => set<Map<String, dynamic>>(keySchedule, schedule.toJson());

  static const keyInterventionOrder = 'intervention_order_ids';
  List<String> get interventionOrder => get<List<dynamic>>(keyInterventionOrder).map<String>((e) => e).toList();
  set interventionOrder(List<String> interventionOrder) => set<List<String>>(keyInterventionOrder, interventionOrder);

  static const keyInterventionSet = 'intervention_set';
  InterventionSet get interventionSet => InterventionSet.fromJson(get<Map<String, dynamic>>(keyInterventionSet));
  set interventionSet(InterventionSet interventionSet) =>
      set<Map<String, dynamic>>(keyInterventionSet, interventionSet.toJson());

  static const keyObservations = 'observations';
  List<Observation> get observations =>
      get<List<dynamic>>(keyObservations)?.map((e) => Observation.fromJson(e))?.toList() ?? [];
  set observations(List<Observation> observations) =>
      set<List<dynamic>>(keyObservations, observations.map((e) => e.toJson()).toList());

  static const keyConsent = 'consent';
  List<ConsentItem> get consent =>
      get<List<dynamic>>(keyConsent, defaultValue: []).map((e) => ConsentItem.fromJson(e)).toList();
  set consent(List<ConsentItem> consent) => set<List<dynamic>>(keyConsent, consent.map((e) => e.toJson()).toList());

  static const keyResults = 'results';
  Map<String, List<Result>> get results =>
      get<Map<String, dynamic>>(keyResults, defaultValue: {}).map<String, List<Result>>((key, resultsData) =>
          MapEntry(key, resultsData.map<Result>((resultData) => Result.fromJson(resultData)).toList()));
  set results(Map<String, List<Result>> results) => set<Map<String, dynamic>>(keyResults,
      results.map<String, dynamic>((key, value) => MapEntry(key, value.map((result) => result.toJson()).toList())));

  static const keyReportSpecification = 'report_specification';
  ReportSpecification get reportSpecification =>
      ReportSpecification.fromJson(get<Map<String, dynamic>>(keyReportSpecification));
  set reportSpecification(ReportSpecification reportSpecification) =>
      set<Map<String, dynamic>>(keyReportSpecification, reportSpecification.toJson());

  void setStartDateBackBy({int days}) {
    startDate = startDate.subtract(Duration(days: days));
    results = results.map((task, results) => MapEntry(
        task,
        results.map((result) {
          final json = result.toJson();
          json['timeStamp'] = result.timeStamp.subtract(Duration(days: days)).toString();
          result = Result.fromJson(json);
          return result;
        }).toList()));
    save();
  }
}
