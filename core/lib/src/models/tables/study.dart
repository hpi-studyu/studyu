import 'package:fhir/r4.dart' as fhir;
import 'package:uuid/uuid.dart';

import '../../env/env.dart';
import '../../util/supabase_object.dart';
import '../models.dart';

class Study extends SupabaseObjectFunctions<Study> {
  static const String tableName = 'study';

  static const String baselineID = '__baseline';
  @override
  String? id;
  String? title;
  String? description;
  Contact contact = Contact();
  String iconName = 'accountHeart';
  bool published = false;
  Questionnaire questionnaire = Questionnaire();
  List<EligibilityCriterion> eligibility = [];
  List<ConsentItem> consent = [];
  InterventionSet interventionSet = InterventionSet([]);
  List<Observation> observations = [];
  StudySchedule schedule = StudySchedule();
  ReportSpecification reportSpecification = ReportSpecification();
  List<StudyResult> results = [];

  fhir.Questionnaire? fhirQuestionnaire;

  Study(this.id);

  Study.withId() : id = Uuid().v4();

  factory Study.fromJson(Map<String, dynamic> json) => Study(json['id'] as String)
    ..title = json['title'] as String?
    ..description = json['description'] as String?
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
    ..reportSpecification = ReportSpecification.fromJson(json['report_specification'] as Map<String, dynamic>)
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
        'report_specification': reportSpecification.toJson(),
        'results': results.map((e) => e.toJson()).toList(),
      };

  // TODO: Add null checks in fromJson to allow selecting columns
  static Future<List<Study>> getResearcherDashboardStudies() async => SupabaseQuery.getAll<Study>(
      /*selectedColumns: ['id', 'title', 'description', 'published', 'icon_name', 'results', 'schedule']*/);

  // ['id', 'title', 'description', 'published', 'icon_name', 'results', 'schedule']
  static Future<List<Study>> publishedStudies() async =>
      SupabaseQuery.extractSupabaseList<Study>(await client.from(tableName).select().eq('published', true).execute());
}
