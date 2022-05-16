import 'package:csv/csv.dart';
import 'package:fhir/r4.dart' show Questionnaire;
import 'package:json_annotation/json_annotation.dart';
import 'package:supabase/supabase.dart';
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
  @JsonKey(name: 'user_id')
  String userId;
  Participation participation = Participation.invite;
  @JsonKey(name: 'result_sharing')
  ResultSharing resultSharing = ResultSharing.private;
  late Contact contact = Contact();
  @JsonKey(name: 'icon_name')
  late String iconName = 'accountHeart';
  late bool published = false;
  late StudyUQuestionnaire questionnaire = StudyUQuestionnaire();
  @JsonKey(name: 'eligibility_criteria')
  late List<EligibilityCriterion> eligibilityCriteria = [];
  late List<ConsentItem> consent = [];
  late List<Intervention> interventions = [];
  late List<Observation> observations = [];
  late StudySchedule schedule = StudySchedule();
  @JsonKey(name: 'report_specification')
  late ReportSpecification reportSpecification = ReportSpecification();
  late List<StudyResult> results = [];
  @JsonKey(name: 'collaborator_emails')
  late List<String> collaboratorEmails = [];

  @JsonKey(name: 'fhir_questionnaire')
  Questionnaire? fhirQuestionnaire;

  @JsonKey(ignore: true)
  int participantCount = 0;
  @JsonKey(ignore: true)
  int endedCount = 0;
  @JsonKey(ignore: true)
  int activeSubjectCount = 0;
  @JsonKey(ignore: true)
  List<int> missedDays = [];

  @JsonKey(ignore: true)
  Repo? repo;

  @JsonKey(ignore: true)
  List<StudyInvite>? invites;

  Study(this.id, this.userId);

  Study.withId(this.userId) : id = const Uuid().v4();

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
    final int? participantCount = json['study_participant_count'] as int?;
    if (participantCount != null) {
      study.participantCount = participantCount;
    }
    final int? endedCount = json['study_ended_count'] as int?;
    if (endedCount != null) {
      study.endedCount = endedCount;
    }
    final int? activeSubjectCount = json['active_subject_count'] as int?;
    if (activeSubjectCount != null) {
      study.activeSubjectCount = activeSubjectCount;
    }
    final List? missedDays = json['study_missed_days'] as List?;
    if (missedDays != null) {
      study.missedDays = List<int>.from(json['study_missed_days'] as List);
    }
    return study;
  }

  @override
  Map<String, dynamic> toJson() => _$StudyToJson(this);

  // TODO: Add null checks in fromJson to allow selecting columns
  static Future<List<Study>> getResearcherDashboardStudies() async => SupabaseQuery.getAll<Study>(
        selectedColumns: [
          '*',
          'repo(*)',
          'study_participant_count',
          'study_ended_count',
          'active_subject_count',
          'study_missed_days'
        ],
      );

  // ['id', 'title', 'description', 'published', 'icon_name', 'results', 'schedule']
  static Future<List<Study>> publishedPublicStudies() async => SupabaseQuery.extractSupabaseList<Study>(
        await env.client.from(tableName).select().eq('participation', 'open').execute(),
      );

  bool isOwner(User? user) => user != null && userId == user.id;

  bool isEditor(User? user) => user != null && collaboratorEmails.contains(user.email);

  bool canEdit(User? user) => user != null && (isOwner(user) || isEditor(user));

  bool get hasEligibilityCheck => eligibilityCriteria.isNotEmpty && questionnaire.questions.isNotEmpty;

  int get totalMissedDays => missedDays.isNotEmpty ? missedDays.reduce((total, days) => total += days) : 0;

  double get percentageMissedDays => totalMissedDays / (participantCount * schedule.length);

  static Future<String> fetchResultsCSVTable(String studyId) async {
    final res = await env.client.from('study_progress').select().eq('study_id', studyId).execute();
    SupabaseQuery.catchPostgrestError(res);

    final jsonList = List<Map<String, dynamic>>.from(res.data as List);
    if (jsonList.isEmpty) return '';
    final tableHeadersSet = jsonList[0].keys.toSet();
    final flattenedQuestions = jsonList.map((progress) {
      if (progress['result_type'] == 'QuestionnaireState') {
        for (final result in List<Map<String, dynamic>>.from(progress['result'] as List)) {
          progress[result['question'] as String] = result['response'];
          tableHeadersSet.add(result['question'] as String);
        }
        // progress.remove('result');
      }
      return progress;
    }).toList(growable: false);
    final tableHeaders = tableHeadersSet.toList();
    // Convert to List and fill empty cells with empty string
    final resultsTable = [
      tableHeaders,
      ...flattenedQuestions
          .map((progress) => tableHeaders.map((header) => progress[header] ?? '').toList(growable: false))
    ];
    return const ListToCsvConverter().convert(resultsTable);
  }
}
