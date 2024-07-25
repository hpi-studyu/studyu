import 'package:csv/csv.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:studyu_core/src/env/env.dart' as env;
import 'package:studyu_core/src/models/models.dart';
import 'package:studyu_core/src/util/supabase_object.dart';
import 'package:supabase/supabase.dart';
import 'package:uuid/uuid.dart';

part 'study.g.dart';

enum StudyStatus {
  draft,
  running,
  closed;

  String toJson() => name;
  static StudyStatus fromJson(String json) => values.byName(json);
}

enum Participation {
  open,
  invite;

  String toJson() => name;
  static Participation fromJson(String json) => values.byName(json);
}

enum ResultSharing {
  public,
  private,
  organization;

  String toJson() => name;
  static ResultSharing fromJson(String json) => values.byName(json);
}

@JsonSerializable()
class Study extends SupabaseObjectFunctions<Study>
    implements Comparable<Study> {
  static const String tableName = 'study';

  @override
  Map<String, Object> get primaryKeys => {'id': id};

  static const String baselineID = '__baseline';
  String id;
  String? title;
  String? description = '';
  @JsonKey(name: 'user_id')
  String userId;
  Participation participation = Participation.invite;
  @JsonKey(name: 'result_sharing')
  ResultSharing resultSharing = ResultSharing.private;
  @JsonKey(fromJson: _contactFromJson)
  late Contact contact = Contact();
  @JsonKey(name: 'icon_name', defaultValue: 'accountHeart')
  late String iconName = 'accountHeart';
  @Deprecated('Use status instead')
  @JsonKey(defaultValue: false)
  late bool published = false;
  late StudyStatus status = StudyStatus.draft;
  @JsonKey(fromJson: _questionnaireFromJson)
  late StudyUQuestionnaire questionnaire = StudyUQuestionnaire();
  @JsonKey(name: 'eligibility_criteria', fromJson: _eligibilityCriteriaFromJson)
  late List<EligibilityCriterion> eligibilityCriteria = [];
  @JsonKey(defaultValue: [])
  late List<ConsentItem> consent = [];
  @JsonKey(defaultValue: [])
  late List<Intervention> interventions = [];
  @JsonKey(defaultValue: [])
  late List<Observation> observations = [];
  @JsonKey(fromJson: _studyScheduleFromJson)
  late StudySchedule schedule = StudySchedule();
  @JsonKey(name: 'report_specification', fromJson: _reportSpecificationFromJson)
  late ReportSpecification reportSpecification = ReportSpecification();
  @JsonKey(defaultValue: [])
  late List<StudyResult> results = [];
  @JsonKey(name: 'collaborator_emails', defaultValue: [])
  late List<String> collaboratorEmails = [];
  @JsonKey(name: 'registry_published', defaultValue: false)
  late bool registryPublished = false;

  @JsonKey(includeToJson: false, includeFromJson: false)
  int participantCount = 0;
  @JsonKey(includeToJson: false, includeFromJson: false)
  int endedCount = 0;
  @JsonKey(includeToJson: false, includeFromJson: false)
  int activeSubjectCount = 0;
  @JsonKey(includeToJson: false, includeFromJson: false)
  List<int> missedDays = [];

  @JsonKey(includeToJson: false, includeFromJson: false)
  Repo? repo;

  @JsonKey(includeToJson: false, includeFromJson: false)
  List<StudyInvite>? invites;

  @JsonKey(includeToJson: false, includeFromJson: false)
  List<StudySubject>? participants;

  @JsonKey(includeToJson: false, includeFromJson: false)
  List<SubjectProgress>? participantsProgress;

  @JsonKey(includeToJson: false, includeFromJson: false)
  DateTime? createdAt;

  Study(this.id, this.userId);

  Study.withId(this.userId) : id = const Uuid().v4();

  static List<EligibilityCriterion> _eligibilityCriteriaFromJson(dynamic json) {
    if (json == null) {
      return [];
    }
    return (json as List)
        .map((e) => EligibilityCriterion.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  static Contact _contactFromJson(dynamic json) {
    if (json is Map<String, dynamic>) {
      return Contact.fromJson(json);
    }
    return Contact();
  }

  static StudySchedule _studyScheduleFromJson(dynamic json) {
    if (json is Map<String, dynamic>) {
      return StudySchedule.fromJson(json);
    }
    return StudySchedule();
  }

  static StudyUQuestionnaire _questionnaireFromJson(dynamic json) {
    if (json is List<dynamic>) {
      return StudyUQuestionnaire.fromJson(json);
    }
    return StudyUQuestionnaire();
  }

  static ReportSpecification _reportSpecificationFromJson(dynamic json) {
    if (json is Map<String, dynamic>) {
      return ReportSpecification.fromJson(json);
    }
    return ReportSpecification();
  }

  factory Study.fromJson(Map<String, dynamic> json) {
    final study = _$StudyFromJson(json);

    final List? repo = json['repo'] as List?;
    if (repo != null && repo.isNotEmpty) {
      study.repo =
          Repo.fromJson((json['repo'] as List)[0] as Map<String, dynamic>);
    }

    final List? invites = json['study_invite'] as List?;
    if (invites != null) {
      study.invites = invites
          .map((json) => StudyInvite.fromJson(json as Map<String, dynamic>))
          .toList();
    }

    final List? participants = json['study_subject'] as List?;
    if (participants != null) {
      study.participants = participants
          .map((json) => StudySubject.fromJson(json as Map<String, dynamic>))
          .toList();
    }

    List? participantsProgress = json['study_progress'] as List?;
    participantsProgress = json['study_progress_export'] as List?;
    participantsProgress ??= json['subject_progress'] as List?;
    if (participantsProgress != null) {
      study.participantsProgress = participantsProgress
          .map((json) => SubjectProgress.fromJson(json as Map<String, dynamic>))
          .toList();
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

    final String? createdAt = json['created_at'] as String?;
    if (createdAt != null && createdAt.isNotEmpty) {
      study.createdAt = DateTime.parse(createdAt);
    }

    return study;
  }

  @override
  Map<String, dynamic> toJson() => _$StudyToJson(this);

  // TODO: Add null checks in fromJson to allow selecting columns
  static Future<List<Study>> getResearcherDashboardStudies() async =>
      SupabaseQuery.getAll<Study>(
        selectedColumns: [
          '*',
          'repo(*)',
          'study_participant_count',
          'study_ended_count',
          'active_subject_count',
          'study_missed_days',
        ],
      );

  /*static Future<List<Study>> getDashboardDisplayStudies() async => SupabaseQuery.getAll<Study>(
    selectedColumns: [
      'id',
      'title',
      'description',
      'user_id',
      'participation',
      'result_sharing',
      'published',
      'registry_published',
      'study_participant_count',
      'study_ended_count',
      'active_subject_count',
    ],
  );*/

  // ['id', 'title', 'description', 'published', 'icon_name', 'results', 'schedule']
  static Future<ExtractionResult<Study>> publishedPublicStudies() async {
    ExtractionResult<Study> result;
    try {
      final response = await env.client
          .from(tableName)
          .select()
          .eq('participation', 'open')
          .neq('status', StudyStatus.closed.name);
      final extracted = SupabaseQuery.extractSupabaseList<Study>(
        List<Map<String, dynamic>>.from(response),
      );
      result = ExtractionSuccess<Study>(extracted);
    } on ExtractionFailedException<Study> catch (error) {
      result = error;
    } catch (error, stacktrace) {
      SupabaseQuery.catchSupabaseException(error, stacktrace);
      rethrow;
    }
    return result;
  }

  bool isOwner(User? user) => user != null && userId == user.id;

  bool isEditor(User? user) =>
      user != null && collaboratorEmails.contains(user.email);

  bool canEdit(User? user) => user != null && (isOwner(user) || isEditor(user));

  bool get hasEligibilityCheck =>
      eligibilityCriteria.isNotEmpty && questionnaire.questions.isNotEmpty;

  bool get hasConsentCheck => consent.isNotEmpty;

  int get totalMissedDays => missedDays.isNotEmpty
      ? missedDays.reduce((total, days) => total += days)
      : 0;

  double get percentageMissedDays =>
      totalMissedDays / (participantCount * schedule.length);

  static Future<String> fetchResultsCSVTable(String studyId) async {
    final List res;
    try {
      res = await env.client
          .from('study_progress')
          .select()
          .eq('study_id', studyId);
    } catch (error, stacktrace) {
      SupabaseQuery.catchSupabaseException(error, stacktrace);
      rethrow;
    }

    final jsonList = List<Map<String, dynamic>>.from(res);
    if (jsonList.isEmpty) return '';
    final tableHeadersSet = jsonList[0].keys.toSet();
    final flattenedQuestions = jsonList.map((progress) {
      if (progress['result_type'] == 'QuestionnaireState') {
        for (final result
            in List<Map<String, dynamic>>.from(progress['result'] as List)) {
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
      ...flattenedQuestions.map(
        (progress) => tableHeaders
            .map((header) => progress[header] ?? '')
            .toList(growable: false),
      ),
    ];
    return const ListToCsvConverter().convert(resultsTable);
  }

  // - Status

  bool get isDraft => status == StudyStatus.draft;
  bool get isRunning => status == StudyStatus.running;
  bool get isClosed => status == StudyStatus.closed;

  bool isReadonly(User user) {
    return status != StudyStatus.draft || !canEdit(user);
  }

  @override
  int compareTo(Study other) {
    return id.compareTo(other.id);
  }
}
