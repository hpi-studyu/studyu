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

  // Internal schedule field that can contain either old StudySchedule or new AdaptiveStudySchedule
  // When reading: supports both formats for backward compatibility
  // When writing: always writes AdaptiveStudySchedule
  @JsonKey(
    name: 'schedule',
    fromJson: _scheduleFromJson,
    toJson: _scheduleToJson,
  )
  dynamic scheduleData;

  @JsonKey(name: 'report_specification', fromJson: _reportSpecificationFromJson)
  late ReportSpecification reportSpecification = ReportSpecification();
  @JsonKey(defaultValue: [])
  late List<StudyResult> results = [];
  @JsonKey(name: 'collaborator_emails', defaultValue: [])
  late List<String> collaboratorEmails = [];
  @JsonKey(name: 'registry_published', defaultValue: false)
  late bool registryPublished = false;

  @JsonKey(includeToJson: false, includeFromJson: false)
  StudyFitbitCredentials? fitbitCredentials;

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

  /// Public schedule property that provides backward compatibility
  /// Returns StudySchedule for old format, or a converted StudySchedule for new format
  /// Apps can use this to access legacy schedule properties like phaseDuration, includeBaseline, etc.
  @JsonKey(includeFromJson: false, includeToJson: false)
  StudySchedule get schedule {
    if (scheduleData is StudySchedule) {
      return scheduleData as StudySchedule;
    }
    // For AdaptiveSchedule, return a default StudySchedule for backward compatibility
    // This is for old app code that still accesses schedule.phaseDuration, etc.
    return StudySchedule();
  }

  set schedule(dynamic value) {
    scheduleData = value;
  }

  /// Get the schedule as AdaptiveStudySchedule
  /// This handles both old StudySchedule and new AdaptiveStudySchedule formats
  @JsonKey(includeFromJson: false, includeToJson: false)
  AdaptiveStudySchedule get adaptiveSchedule {
    if (scheduleData is AdaptiveStudySchedule) {
      return scheduleData as AdaptiveStudySchedule;
    } else if (scheduleData is StudySchedule) {
      return _migrateStudyScheduleToAdaptive(scheduleData as StudySchedule);
    }
    return AdaptiveStudySchedule();
  }

  /// Set the adaptive schedule
  /// This updates the internal scheduleData field
  set adaptiveSchedule(AdaptiveStudySchedule value) {
    scheduleData = value;
    // Note: The scheduleData field itself will trigger autosave since it's a
    // public field tracked by json_serializable. When used with reactive_forms
    // in the designer, changes will be detected through form.valueChanges
  }

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

  /// Reads schedule from JSON, supporting both old StudySchedule and new AdaptiveStudySchedule
  static dynamic _scheduleFromJson(dynamic json) {
    if (json is Map<String, dynamic>) {
      // Check if it's an AdaptiveStudySchedule (has 'segments' field)
      if (json.containsKey('segments')) {
        return AdaptiveStudySchedule.fromJson(json);
      }
      // Otherwise it's an old StudySchedule
      return StudySchedule.fromJson(json);
    }
    // Default to empty AdaptiveStudySchedule
    return AdaptiveStudySchedule();
  }

  /// Writes schedule to JSON, always writes AdaptiveStudySchedule
  static Map<String, dynamic> _scheduleToJson(dynamic scheduleData) {
    if (scheduleData is AdaptiveStudySchedule) {
      return scheduleData.toJson();
    } else if (scheduleData is StudySchedule) {
      // Migrate old StudySchedule to AdaptiveStudySchedule on save
      return _migrateStudyScheduleToAdaptive(scheduleData).toJson();
    }
    return AdaptiveStudySchedule().toJson();
  }

  /// Migrates old StudySchedule to AdaptiveStudySchedule
  static AdaptiveStudySchedule _migrateStudyScheduleToAdaptive(
    StudySchedule oldSchedule,
  ) {
    final segments = <StudyScheduleSegment>[];

    // Add baseline if included
    if (oldSchedule.includeBaseline) {
      segments.add(BaselineScheduleSegment(oldSchedule.phaseDuration));
    }

    // Add intervention segments based on sequence type
    switch (oldSchedule.sequence) {
      case PhaseSequence.alternating:
        segments.add(
          AlternatingScheduleSegment(
            oldSchedule.phaseDuration,
            oldSchedule.numberOfCycles,
          ),
        );
      case PhaseSequence.counterBalanced:
        segments.add(
          CounterBalancedScheduleSegment(
            oldSchedule.phaseDuration,
            oldSchedule.numberOfCycles,
          ),
        );
      case PhaseSequence.randomized:
      case PhaseSequence.customized:
        // For randomized and customized, use alternating as fallback
        // (better migration logic can be added if needed)
        segments.add(
          AlternatingScheduleSegment(
            oldSchedule.phaseDuration,
            oldSchedule.numberOfCycles,
          ),
        );
    }

    return AdaptiveStudySchedule.withSegments(segments);
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

    // Manually deserialize schedule field with custom deserialization
    if (json.containsKey('schedule')) {
      study.scheduleData = _scheduleFromJson(json['schedule']);
    }

    final fitbitCredentials =
        json['study_fitbit_credentials'] as Map<String, dynamic>?;
    if (fitbitCredentials != null && fitbitCredentials.isNotEmpty) {
      study.fitbitCredentials = StudyFitbitCredentials.fromJson(
        json['study_fitbit_credentials'] as Map<String, dynamic>,
      );
    }

    final List? repo = json['repo'] as List?;
    if (repo != null && repo.isNotEmpty) {
      study.repo = Repo.fromJson(
        (json['repo'] as List)[0] as Map<String, dynamic>,
      );
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
  Map<String, dynamic> toJson() {
    final json = _$StudyToJson(this);
    // Manually add schedule field with custom serialization
    json['schedule'] = _scheduleToJson(scheduleData);
    return json;
  }

  // TODO: Add null checks in fromJson to allow selecting columns
  static Future<List<Study>> getResearcherDashboardStudies() =>
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
        throwForNonExtracted: true,
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

  double get percentageMissedDays {
    final schedLength = adaptiveSchedule.segments.isEmpty
        ? (scheduleData is StudySchedule
              ? (scheduleData as StudySchedule).length
              : 0)
        : studyDuration;
    return schedLength > 0
        ? totalMissedDays / (participantCount * schedLength)
        : 0;
  }

  int get studyDuration => adaptiveSchedule.segments.isEmpty
      ? 0
      : adaptiveSchedule.segments
            .map((e) => e.getDuration(interventions))
            .reduce((a, b) => a + b);

  /// Returns the segment for the given day and the nth day of the segment
  (StudyScheduleSegment?, int) getSegmentForDay(int day) {
    if (day >= studyDuration || day < 0) {
      throw ArgumentError("Day must be between 0 and $studyDuration");
    }

    int remainingDays = day;

    for (final segment in adaptiveSchedule.segments) {
      final int segmentDuration = segment.getDuration(interventions);
      if (segmentDuration > remainingDays) {
        return (segment, remainingDays);
      } else {
        remainingDays -= segmentDuration;
      }
    }

    throw StateError("This should never happen");
  }

  Intervention? getInterventionForDay(int day, List<SubjectProgress> progress) {
    final (segment, dayInSegment) = getSegmentForDay(day);
    return segment?.getInterventionOnDay(dayInSegment, interventions, progress);
  }

  int get studyLength {
    // If using AdaptiveSchedule, use studyDuration
    if (scheduleData is AdaptiveStudySchedule ||
        adaptiveSchedule.segments.isNotEmpty) {
      return studyDuration;
    }

    // Otherwise calculate from old StudySchedule if present
    if (scheduleData is! StudySchedule) {
      return 0;
    }

    final scheduleObj = scheduleData as StudySchedule;
    final phaseDuration = scheduleObj.phaseDuration;
    final numberOfCycles = scheduleObj.numberOfCycles;
    final includeBaseline = scheduleObj.includeBaseline;

    // default: 2 phases per cycle for alternating/counterbalanced/random
    int phasesPerCycle = StudySchedule.numberOfInterventions;

    if (scheduleObj.sequence == PhaseSequence.customized) {
      final String customSequence = scheduleObj.sequenceCustom.trim();
      if (customSequence.isEmpty) {
        phasesPerCycle = 0;
      } else {
        // count number of phases in custom sequence
        phasesPerCycle = customSequence.length;
      }
    }

    final baselineLength = includeBaseline ? phaseDuration : 0;
    final studyLength =
        baselineLength + phaseDuration * numberOfCycles * phasesPerCycle;

    return studyLength;
  }

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
    final flattenedQuestions = jsonList
        .map((progress) {
          if (progress['result_type'] == 'QuestionnaireState') {
            for (final result in List<Map<String, dynamic>>.from(
              progress['result'] as List,
            )) {
              progress[result['question'] as String] = result['response'];
              tableHeadersSet.add(result['question'] as String);
            }
            // progress.remove('result');
          }
          return progress;
        })
        .toList(growable: false);
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
