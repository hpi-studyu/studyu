import 'package:csv/csv.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:studyu_core/src/env/env.dart' as env;
import 'package:studyu_core/src/models/models.dart';
import 'package:studyu_core/src/models/template/template_configuration.dart';
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

enum StudyType {
  standalone,
  template,
  subStudy;

  String toJson() => name;
  static StudyType fromJson(String json) => values.byName(json);
}

@JsonSerializable()
class Study extends SupabaseObjectFunctions<Study> implements Comparable<Study> {
  static const String tableName = 'study';

  @override
  Map<String, dynamic> get primaryKeys => {'id': id};

  static const String baselineID = '__baseline';
  String id;
  @JsonKey(name: 'parent_template_id')
  String? parentTemplateId;
  @JsonKey(name: 'template_configuration')
  TemplateConfiguration? templateConfiguration;
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
  @JsonKey(name: 'registry_published')
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

  Study.create(this.userId) : id = const Uuid().v4();

  factory Study.fromJson(Map<String, dynamic> json) {
    final parentTemplateId = json['parent_template_id'] as String?;
    final templateConfiguration = json['template_configuration'];
    final study = parentTemplateId != null
        ? _$TemplateSubStudyFromJson(json)
        : (templateConfiguration != null ? _$TemplateFromJson(json) : _$StudyFromJson(json));

    final List? repo = json['repo'] as List?;
    if (repo != null && repo.isNotEmpty) {
      study.repo = Repo.fromJson((json['repo'] as List)[0] as Map<String, dynamic>);
    }

    final List? invites = json['study_invite'] as List?;
    if (invites != null) {
      study.invites = invites.map((json) => StudyInvite.fromJson(json as Map<String, dynamic>)).toList();
    }

    final List? participants = json['study_subject'] as List?;
    if (participants != null) {
      study.participants = participants.map((json) => StudySubject.fromJson(json as Map<String, dynamic>)).toList();
    }

    List? participantsProgress = json['study_progress'] as List?;
    participantsProgress = json['study_progress_export'] as List?;
    participantsProgress ??= json['subject_progress'] as List?;
    if (participantsProgress != null) {
      study.participantsProgress =
          participantsProgress.map((json) => SubjectProgress.fromJson(json as Map<String, dynamic>)).toList();
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
  static Future<List<Study>> getResearcherDashboardStudies() async => SupabaseQuery.getAll<Study>(
        selectedColumns: [
          '*',
          'repo(*)',
          'study_participant_count',
          'study_ended_count',
          'active_subject_count',
          'study_missed_days',
        ],
      );

  // ['id', 'title', 'description', 'published', 'icon_name', 'results', 'schedule']
  static Future<List<Study>> publishedPublicStudies() async {
    try {
      final response = await env.client.from(tableName).select().eq('participation', 'open') as List;
      return SupabaseQuery.extractSupabaseList<Study>(List<Map<String, dynamic>>.from(response));
    } catch (error, stacktrace) {
      SupabaseQuery.catchSupabaseException(error, stacktrace);
      rethrow;
    }
  }

  StudyType get type {
    if (parentTemplateId != null) {
      return StudyType.subStudy;
    }
    if (templateConfiguration != null) {
      return StudyType.template;
    }
    return StudyType.standalone;
  }

  bool get isStandalone => type == StudyType.standalone;
  bool get isTemplate => type == StudyType.template;
  bool get isSubStudy => type == StudyType.subStudy;

  bool isOwner(User? user) => user != null && userId == user.id;

  bool isEditor(User? user) => user != null && collaboratorEmails.contains(user.email);

  bool canEdit(User? user) => user != null && (isOwner(user) || isEditor(user));

  bool get hasEligibilityCheck => eligibilityCriteria.isNotEmpty && questionnaire.questions.isNotEmpty;

  bool get hasConsentCheck => consent.isNotEmpty;

  int get totalMissedDays => missedDays.isNotEmpty ? missedDays.reduce((total, days) => total += days) : 0;

  double get percentageMissedDays => totalMissedDays / (participantCount * schedule.length);

  static Future<String> fetchResultsCSVTable(String studyId) async {
    final List res;
    try {
      res = await env.client.from('study_progress').select().eq('study_id', studyId) as List;
    } catch (error, stacktrace) {
      SupabaseQuery.catchSupabaseException(error, stacktrace);
      rethrow;
    }

    final jsonList = List<Map<String, dynamic>>.from(res);
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
      ...flattenedQuestions.map(
        (progress) => tableHeaders.map((header) => progress[header] ?? '').toList(growable: false),
      ),
    ];
    return const ListToCsvConverter().convert(resultsTable);
  }

  // - Status

  StudyStatus get status {
    if (published) {
      return StudyStatus.running;
    }
    return StudyStatus.draft;
  }

  bool get isDraft => status == StudyStatus.draft;
  bool get isRunning => status == StudyStatus.running;
  // TODO: missing flag to indicate that study is completed & enrollment closed
  bool get isClosed => false;

  bool isReadonly(User user) {
    return status != StudyStatus.draft || !canEdit(user);
  }

  @override
  String toString() {
    return 'Study{id: $id, title: $title, description: $description, userId: $userId, participation: $participation, resultSharing: $resultSharing, contact: $contact, iconName: $iconName, published: $published, questionnaire: $questionnaire, eligibilityCriteria: $eligibilityCriteria, consent: $consent, interventions: $interventions, observations: $observations, schedule: $schedule, reportSpecification: $reportSpecification, results: $results, collaboratorEmails: $collaboratorEmails, registryPublished: $registryPublished, participantCount: $participantCount, endedCount: $endedCount, activeSubjectCount: $activeSubjectCount, missedDays: $missedDays, repo: $repo, invites: $invites, participants: $participants, participantsProgress: $participantsProgress, createdAt: $createdAt}';
  }

  @override
  int compareTo(Study other) {
    return id.compareTo(other.id);
  }
}

@JsonSerializable()
class Template extends Study {
  Template(super.id, super.userId);

  Template.create(String userId) : super(const Uuid().v4(), userId) {
    templateConfiguration = TemplateConfiguration();
  }
}

@JsonSerializable()
class TemplateSubStudy extends Study {
  TemplateSubStudy(super.id, super.userId);

  TemplateSubStudy.create(String userId, Template template) : super(const Uuid().v4(), userId) {
    if (template.templateConfiguration == null) {
      throw ArgumentError('Template must have a templateConfiguration');
    }
    parentTemplateId = template.id;
    templateConfiguration =
        template.templateConfiguration!.copyWith(title: template.title, description: template.description);
    participation = template.participation;
    resultSharing = template.resultSharing;
    contact = template.contact;
    iconName = template.iconName;
    questionnaire = template.questionnaire;
    eligibilityCriteria = template.eligibilityCriteria;
    consent = template.consent;
    interventions = template.interventions;
    observations = template.observations;
    schedule = template.schedule;
    reportSpecification = template.reportSpecification;
    collaboratorEmails = template.collaboratorEmails;
    registryPublished = template.registryPublished;
  }
}
