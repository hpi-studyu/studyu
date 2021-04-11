import 'package:fhir/r4.dart' as fhir;
import 'package:uuid/uuid.dart';

import '../../util/supabase_object.dart';
import '../consent/consent_item.dart';
import '../contact.dart';
import '../models.dart';

class Study extends SupabaseObjectFunctions<Study> {
  static const String baselineID = '__baseline';

  @override
  String tableName = 'study';
  @override
  String id;
  String title;
  String description;
  Contact contact;
  String iconName;
  bool published;
  Questionnaire questionnaire;
  List<EligibilityCriterion> eligibility;
  List<ConsentItem> consent;
  InterventionSet interventionSet;
  List<Observation> observations;
  StudySchedule schedule;
  ReportSpecification reportSpecification;
  List<StudyResult> results;

  fhir.Questionnaire fhirQuestionnaire;

  Study();

  Study.designerDefault()
      : id = Uuid().v4(),
        iconName = '',
        published = false,
        contact = Contact.designerDefault(),
        interventionSet = InterventionSet.designerDefault(),
        questionnaire = Questionnaire.designerDefault(),
        eligibility = [],
        observations = [],
        consent = [],
        schedule = StudySchedule.designerDefault(),
        reportSpecification = ReportSpecification.designerDefault(),
        results = [];

  @override
  Study fromJson(Map<String, dynamic> json) => Study()
    ..id = json['id'] as String
    ..title = json['title'] as String
    ..description = json['description'] as String
    ..contact = Contact.fromJson(json['contact'] as Map<String, dynamic>)
    ..iconName = json['icon_name'] as String
    ..published = json['published'] as bool
    ..questionnaire = Questionnaire.fromJson(json['questionnaire'] as List)
    ..eligibility = json['eligibility_criteria'] != null
        ? ((json['eligibility_criteria'] as List)
            .map((e) => EligibilityCriterion.fromJson(e as Map<String, dynamic>))
            .toList())
        : []
    ..consent = (json['consent'] as List).map((e) => ConsentItem.fromJson(e as Map<String, dynamic>)).toList()
    ..interventionSet = InterventionSet.fromJson(json['intervention_set'] as Map<String, dynamic>)
    ..observations = (json['observations'] as List).map((e) => Observation.fromJson(e as Map<String, dynamic>)).toList()
    ..schedule = StudySchedule.fromJson(json['schedule'] as Map<String, dynamic>)
    ..reportSpecification = json['report_specification'] != null
        ? ReportSpecification.fromJson(json['report_specification'] as Map<String, dynamic>)
        : null
    ..results = (json['results'] as List).map((e) => StudyResult.fromJson(e as Map<String, dynamic>)).toList();

  @override
  Map<String, dynamic> toJson() => <String, dynamic>{
        'id': id,
        'title': title,
        'description': description,
        'contact': contact.toJson(),
        'icon_name': iconName,
        'published': published,
        'questionnaire': questionnaire.toJson(),
        'eligibility_criteria': eligibility.map((e) => e.toJson()).toList(),
        'consent': consent.map((e) => e.toJson()).toList(),
        'intervention_set': interventionSet.toJson(),
        'observations': observations.map((e) => e.toJson()).toList(),
        'schedule': schedule.toJson(),
        'report_specification': reportSpecification?.toJson(),
        'results': results.map((e) => e.toJson()).toList(),
      };

  UserStudy extractUserStudy(
      String userId, List<Intervention> selectedInterventions, DateTime startDate, int firstIntervention) {
    final userStudy = UserStudy()
      ..title = title
      ..description = description
      ..contact = contact
      ..iconName = iconName
      ..studyId = id
      ..userId = userId
      ..startDate = startDate
      ..interventionSet = InterventionSet(selectedInterventions)
      ..observations = observations ?? []
      ..reportSpecification = reportSpecification
      ..fhirQuestionnaire = fhirQuestionnaire;
    if (schedule != null) {
      const baselineId = Study.baselineID;
      var addBaseline = false;
      userStudy
        ..schedule = schedule
        ..consent = consent
        ..interventionOrder = schedule.generateWith(firstIntervention).map<String>((int index) {
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

  // TODO: Add null checks in fromJson to allow selecting columns
  Future<List<Study>> getResearcherDashboardStudies() async =>
      getAll(/*selectedColumns: ['id', 'title', 'description', 'published', 'icon_name', 'results', 'schedule']*/);

  // ['id', 'title', 'description', 'published', 'icon_name', 'results', 'schedule']
  Future<List<Study>> publishedStudies() async =>
      extractSupabaseList(await client.from(tableName).select().eq('published', true).execute());
}
