import 'package:fhir/r4.dart' as fhir;
import 'package:parse_server_sdk_flutter/parse_server_sdk.dart';

import '../../util/user.dart';
import '../models.dart';
import 'contact.dart';

class ParseUserStudy extends ParseObject implements ParseCloneable, UserStudyBase {
  static const _keyTableName = 'UserStudy';

  ParseUserStudy() : super(_keyTableName);

  ParseUserStudy.clone() : this();

  factory ParseUserStudy.fromBase(UserStudyBase userStudy) {
    return ParseUserStudy()
      ..studyId = userStudy.studyId
      ..userId = userStudy.userId
      ..title = userStudy.title
      ..description = userStudy.description
      ..contact = userStudy.contact
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
  ParseUserStudy clone(Map<String, dynamic> map) {
    return ParseUserStudy.clone()..fromJson(map);
  }

  static const keyStudyId = 'study_id';

  @override
  String get studyId => get<String>(keyStudyId);

  @override
  set studyId(String studyId) => set<String>(keyStudyId, studyId);

  static const keyUserId = 'user_id';

  @override
  String get userId => get<String>(keyUserId);

  @override
  set userId(String userId) => set<String>(keyUserId, userId);

  static const keyTitle = 'title';

  @override
  String get title => get<String>(keyTitle);

  @override
  set title(String title) => set<String>(keyTitle, title);

  static const keyDescription = 'description';

  @override
  String get description => get<String>(keyDescription);

  @override
  set description(String description) => set<String>(keyDescription, description);

  static const keyContact = 'contact';

  @override
  Contact get contact {
    final contactMap = get<Map<String, dynamic>>(keyContact);
    if (contactMap == null) return null;
    return Contact.fromJson(contactMap);
  }

  @override
  set contact(Contact contact) => set<Map<String, dynamic>>(keyContact, contact.toJson());

  static const keyIconName = 'icon_name';

  @override
  String get iconName => get<String>(keyIconName);

  @override
  set iconName(String iconName) => set<String>(keyIconName, iconName);

  static const keyStartDate = 'start_date';

  @override
  DateTime get startDate => get<DateTime>(keyStartDate);

  @override
  set startDate(DateTime startDate) => set<DateTime>(keyStartDate, startDate);

  static const keySchedule = 'schedule';

  @override
  StudySchedule get schedule => StudySchedule.fromJson(get<Map<String, dynamic>>(keySchedule));

  @override
  set schedule(StudySchedule schedule) => set<Map<String, dynamic>>(keySchedule, schedule.toJson());

  static const keyInterventionOrder = 'intervention_order_ids';

  @override
  List<String> get interventionOrder => List<String>.from(get<List<dynamic>>(keyInterventionOrder));

  @override
  set interventionOrder(List<String> interventionOrder) => set<List<String>>(keyInterventionOrder, interventionOrder);

  static const keyInterventionSet = 'intervention_set';

  @override
  InterventionSet get interventionSet => InterventionSet.fromJson(get<Map<String, dynamic>>(keyInterventionSet));

  @override
  set interventionSet(InterventionSet interventionSet) =>
      set<Map<String, dynamic>>(keyInterventionSet, interventionSet.toJson());

  static const keyObservations = 'observations';

  @override
  List<Observation> get observations =>
      get<List<dynamic>>(keyObservations)?.map((e) => Observation.fromJson(e as Map<String, dynamic>))?.toList() ?? [];

  @override
  set observations(List<Observation> observations) =>
      set<List<dynamic>>(keyObservations, observations.map((e) => e.toJson()).toList());

  static const keyConsent = 'consent';

  @override
  List<ConsentItem> get consent => get<List<dynamic>>(keyConsent, defaultValue: [])
      .map((e) => ConsentItem.fromJson(e as Map<String, dynamic>))
      .toList();

  @override
  set consent(List<ConsentItem> consent) => set<List<dynamic>>(keyConsent, consent.map((e) => e.toJson()).toList());

  static const keyResults = 'results';

  @override
  Map<String, List<Result>> get results =>
      get<Map<String, dynamic>>(keyResults, defaultValue: {}).map<String, List<Result>>((key, resultsData) {
        final results = (resultsData as List)
            .map<Result>((resultData) => Result.fromJson(resultData as Map<String, dynamic>))
            .toList();
        return MapEntry(key, results);
      });

  @override
  set results(Map<String, List<Result>> results) => set<Map<String, dynamic>>(keyResults,
      results.map<String, dynamic>((key, value) => MapEntry(key, value.map((result) => result.toJson()).toList())));

  static const keyReportSpecification = 'report_specification';

  @override
  ReportSpecification get reportSpecification =>
      ReportSpecification.fromJson(get<Map<String, dynamic>>(keyReportSpecification));

  @override
  set reportSpecification(ReportSpecification reportSpecification) =>
      set<Map<String, dynamic>>(keyReportSpecification, reportSpecification.toJson());

  static const keyFhirQuestionnaire = 'fhir_questionnaire';
  @override
  fhir.Questionnaire get fhirQuestionnaire {
    final parseQuestionnaire = get<Map<String, dynamic>>(keyFhirQuestionnaire);
    if (parseQuestionnaire != null) {
      return fhir.Questionnaire.fromJson(parseQuestionnaire);
    } else {
      return null;
    }
  }

  @override
  set fhirQuestionnaire(fhir.Questionnaire questionnaire) =>
      set<Map<String, dynamic>>(keyFhirQuestionnaire, questionnaire?.toJson());

  void setStartDateBackBy({int days}) {
    startDate = startDate.subtract(Duration(days: days));
    results = results.map((task, results) => MapEntry(
        task,
        results.map((result) {
          final json = result.toJson();
          json['timeStamp'] = result.timeStamp.subtract(Duration(days: days)).toString();
          return Result.fromJson(json);
        }).toList()));
    save();
  }
}

extension UserStudyQueries on ParseUserStudy {
  Future<ParseResponse> getUserStudiesFor(ParseStudy study) async {
    final builder = QueryBuilder<ParseUserStudy>(this)..whereEqualTo('study_id', study.id);
    return builder.query();
  }

  Future<ParseUserStudy> getUserStudy(String objectId) async {
    final builder = QueryBuilder<ParseUserStudy>(this)..whereEqualTo('objectId', objectId);
    return builder.query().then((response) =>
        response.success && response.results.isNotEmpty ? response.results.first as ParseUserStudy : null);
  }

  Future<String> saveUserStudy() async {
    final response = await save();
    if (response.success) {
      return objectId;
    }
    print('Could not save UserStudy!');
    return null;
  }

  Future<ParseResponse> getStudyHistory() async {
    final builder = QueryBuilder<ParseUserStudy>(this)
      ..whereEqualTo(ParseUserStudy.keyUserId, await UserQueries.getOrCreateUser().then((user) => user.objectId));
    return builder.query();
  }
}
