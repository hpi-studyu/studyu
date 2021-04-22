import 'package:fhir/r4.dart' as fhir;
import 'package:json_annotation/json_annotation.dart';
import 'package:uuid/uuid.dart';

import '../../env/env.dart' as env;
import '../../util/supabase_object.dart';
import '../models.dart';

part 'study.g.dart';

@JsonSerializable()
class Study extends SupabaseObjectFunctions<Study> {
  static const String tableName = 'study';

  static const String baselineID = '__baseline';
  @override
  String? id;
  String? title;
  String? description;
  late Contact contact = Contact();
  late String iconName = 'accountHeart';
  late bool published = false;
  late Questionnaire questionnaire = Questionnaire();
  late List<EligibilityCriterion> eligibilityCriteria = [];
  late List<ConsentItem> consent = [];
  late List<Intervention> interventions = [];
  late List<Observation> observations = [];
  late StudySchedule schedule = StudySchedule();
  late ReportSpecification reportSpecification = ReportSpecification();
  late List<StudyResult> results = [];

  fhir.Questionnaire? fhirQuestionnaire;

  Study(this.id);

  Study.withId() : id = Uuid().v4();

  factory Study.fromJson(Map<String, dynamic> json) => _$StudyFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$StudyToJson(this);

  // TODO: Add null checks in fromJson to allow selecting columns
  static Future<List<Study>> getResearcherDashboardStudies() async => SupabaseQuery.getAll<Study>(
      /*selectedColumns: ['id', 'title', 'description', 'published', 'icon_name', 'results', 'schedule']*/);

  // ['id', 'title', 'description', 'published', 'icon_name', 'results', 'schedule']
  static Future<List<Study>> publishedStudies() async => SupabaseQuery.extractSupabaseList<Study>(
      await env.client.from(tableName).select().eq('published', true).execute());
}
