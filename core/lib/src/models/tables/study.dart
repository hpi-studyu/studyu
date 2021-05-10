import 'package:fhir/r4.dart' show Questionnaire;
import 'package:json_annotation/json_annotation.dart';
import 'package:uuid/uuid.dart';

import '../../env/env.dart' as env;
import '../../util/supabase_object.dart';
import '../models.dart';
import 'repo.dart';

part 'study.g.dart';

enum StudyVisibility { public, private, organization, invite }

@JsonSerializable()
class Study extends SupabaseObjectFunctions<Study> {
  static const String tableName = 'study';

  @override
  Map<String, dynamic> get primaryKeys => {'id': id};

  static const String baselineID = '__baseline';
  String id;
  String? title;
  String? description;
  String userId;
  StudyVisibility visibility = StudyVisibility.private;
  late Contact contact = Contact();
  late String iconName = 'accountHeart';
  late bool published = false;
  late StudyUQuestionnaire questionnaire = StudyUQuestionnaire();
  late List<EligibilityCriterion> eligibilityCriteria = [];
  late List<ConsentItem> consent = [];
  late List<Intervention> interventions = [];
  late List<Observation> observations = [];
  late StudySchedule schedule = StudySchedule();
  late ReportSpecification reportSpecification = ReportSpecification();
  late List<StudyResult> results = [];

  Questionnaire? fhirQuestionnaire;

  @JsonKey(ignore: true)
  Repo? repo;

  Study(this.id, this.userId);

  Study.withId(this.userId) : id = Uuid().v4();

  factory Study.fromJson(Map<String, dynamic> json) {
    final study = _$StudyFromJson(json);
    final List? repo = json['repo'] as List?;
    if (repo != null && repo.isNotEmpty) {
      study.repo = Repo.fromJson((json['repo'] as List)[0] as Map<String, dynamic>);
    }
    return study;
  }

  @override
  Map<String, dynamic> toJson() => _$StudyToJson(this);

  // TODO: Add null checks in fromJson to allow selecting columns
  static Future<List<Study>> getResearcherDashboardStudies() async =>
      SupabaseQuery.getAll<Study>(selectedColumns: ['*', 'repo(*)']
          /*selectedColumns: ['id', 'title', 'description', 'published', 'icon_name', 'results', 'schedule']*/);

  // ['id', 'title', 'description', 'published', 'icon_name', 'results', 'schedule']
  static Future<List<Study>> publishedPublicStudies() async => SupabaseQuery.extractSupabaseList<Study>(
      await env.client.from(tableName).select().eq('published', true).eq('visibility', 'public').execute());
}
