import 'package:fhir/r4.dart' show Questionnaire;
import 'package:json_annotation/json_annotation.dart';
import 'package:uuid/uuid.dart';

import '../../env/env.dart' as env;
import '../../util/supabase_object.dart';
import '../models.dart';

part 'study.g.dart';

enum Participation { open, invite }
enum ResultSharing { public, private, organization }

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
  Participation participation = Participation.invite;
  @JsonKey(name: 'result_sharing')
  ResultSharing resultSharing = ResultSharing.private;
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
  int participantCount = 0;
  @JsonKey(ignore: true)
  int completedCount = 0;
  @JsonKey(ignore: true)
  int activeSubjectCount = 0;

  @JsonKey(ignore: true)
  Repo? repo;

  @JsonKey(ignore: true)
  List<StudyInvite>? invites;

  Study(this.id, this.userId);

  Study.withId(this.userId) : id = Uuid().v4();

  factory Study.fromJson(Map<String, dynamic> json) {
    final study = _$StudyFromJson(json);
    final List? repo = json['repo'] as List?;
    if (repo != null && repo.isNotEmpty) {
      study.repo = Repo.fromJson((json['repo'] as List)[0] as Map<String, dynamic>);
    }
    final List? invites = json['study_invite'] as List?;
    if (invites != null) {
      study.invites = invites.map((json) => StudyInvite.fromJson(json as Map<String, dynamic>)).toList();
    }
    study
      ..participantCount = json['study_participant_count'] as int
      ..completedCount = json['study_completed_count'] as int
      ..activeSubjectCount = json['active_subject_count'] as int;
    return study;
  }

  @override
  Map<String, dynamic> toJson() => _$StudyToJson(this);

  // TODO: Add null checks in fromJson to allow selecting columns
  static Future<List<Study>> getResearcherDashboardStudies() async => SupabaseQuery.getAll<Study>(
      selectedColumns: ['*', 'repo(*)', 'study_participant_count', 'study_completed_count', 'active_subject_count']);

  // ['id', 'title', 'description', 'published', 'icon_name', 'results', 'schedule']
  static Future<List<Study>> publishedPublicStudies() async => SupabaseQuery.extractSupabaseList<Study>(
      await env.client.from(tableName).select().eq('participation', 'open').execute());

  bool isOwner(String userId) => this.userId == userId;
}
