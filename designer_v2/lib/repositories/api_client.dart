import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:studyu_core/core.dart';
import 'package:studyu_designer_v2/domain/study.dart';
import 'package:studyu_designer_v2/domain/study_invite.dart';
import 'package:studyu_designer_v2/domain/study_subject.dart';
import 'package:studyu_designer_v2/repositories/supabase_client.dart';
import 'package:studyu_designer_v2/utils/debug_print.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

part 'api_client.g.dart';

abstract class StudyUApi {
  Future<Study> saveStudy(Study study);

  Future<Study> fetchStudy(StudyID studyId);

  Future<List<Study>> getUserStudies({
    bool withParticipantActivity = false,
    bool forDashboardDisplay = false,
  });

  Future<void> deleteStudy(Study study);

  Future<StudyInvite> saveStudyInvite(StudyInvite invite);

  Future<StudyInvite> fetchStudyInvite(String code);

  Future<List<StudyInvite>> fetchStudyInvitesPage(
    StudyID studyId, {
    required int offset,
    required int limit,
    String? query,
    InviteCodeFilters filters = const InviteCodeFilters(),
    InviteCodesSortColumn sortBy = InviteCodesSortColumn.code,
    bool ascending = true,
  });

  Future<int> countStudyInvites(
    StudyID studyId, {
    String? query,
    InviteCodeFilters filters = const InviteCodeFilters(),
  });

  Future<Study> fetchStudyFromInvite(String code);

  Future<void> deleteStudyInvite(StudyInvite invite);

  Future<void> deleteStudyInvites(StudyID studyId);

  Future<List<StudySubject>> deleteParticipants(
    Study study,
    List<StudySubject> participants,
  );

  /*
  Future<List<SubjectProgress>> deleteStudyProgress(
      Study study, List<SubjectProgress> records);
   */
  Future<AppConfig> fetchAppConfig();

  Future<StudyUUser> fetchUser(String userId);

  Future<StudyUUser> saveUser(StudyUUser user);

  Future<StudyFitbitCredentials> saveStudyFitbitCredentials(
    StudyFitbitCredentials credentials,
  );

  Future<StudyFitbitCredentials> fetchStudyFitbitCredentials(StudyID studyId);

  Future<void> deleteStudyFitbitCredentials(StudyFitbitCredentials credentials);
}

typedef SupabaseQueryExceptionHandler = void Function(SupabaseQueryError error);

/// Base class for domain-specific exceptions
class APIException implements Exception {}

class StudyNotFoundException extends APIException {}

class MeasurementNotFoundException extends APIException {}

class QuestionNotFoundException extends APIException {}

class ConsentItemNotFoundException extends APIException {}

class InterventionNotFoundException extends APIException {}

class InterventionTaskNotFoundException extends APIException {}

class ReportNotFoundException extends APIException {}

class ReportSectionNotFoundException extends APIException {}

class StudyInviteNotFoundException extends APIException {}

class UserNotFoundException extends APIException {}

abstract class PostgrestErrorCodes {
  static const String isNotSingleItem = 'PGRST116';
}

class StudyUApiClient extends SupabaseClientDependant
    with SupabaseQueryMixin
    implements StudyUApi {
  StudyUApiClient({
    required this.supabaseClient,
    this.testDelayMilliseconds = 0,
  });

  /// Reference to the [SupabaseClient] injected via Riverpod
  @override
  final SupabaseClient supabaseClient;

  static final studyColumns = [
    '*',
    'repo(*)',
    'study_invite!study_invite_studyId_fkey(*)',
    'study_fitbit_credentials!study_fitbit_credentials_studyId_fkey(*)',
    'study_participant_count',
    'study_ended_count',
    'active_subject_count',
    'study_missed_days',
  ];

  static final studyDisplayColumns = [
    'id',
    'title',
    'description',
    'user_id',
    'participation',
    'result_sharing',
    'status',
    'registry_published',
    'study_participant_count',
    'study_ended_count',
    'active_subject_count',
    'contact',
    'created_at',
  ];

  static final studyWithParticipantActivityColumns = [
    ...studyColumns,
    'study_subject!study_subject_studyId_fkey(*)',
    'study_progress_export(*)',
  ];

  final int testDelayMilliseconds;

  @override
  Future<List<StudySubject>> deleteParticipants(
    Study study,
    List<StudySubject> participants,
  ) async {
    await _testDelay();
    if (participants.isEmpty) {
      return Future.value([]);
    }
    final selectionCriteria = participants.first.foreignKey(study);
    final request = deleteAll<StudySubject>(selectionCriteria);
    return _awaitGuarded(request);
  }

  /*
  @override
  Future<List<SubjectProgress>> deleteStudyProgress(
      Study study, List<SubjectProgress> records) async {
    await _testDelay();
    if (records.isEmpty) {
      return Future.value([]);
    }
    final selectionCriteria = records
        .map((record) => {...record.primaryKeys, ...record.foreignKey(study)})
        .toList();
    final request = deleteAll<SubjectProgress>(selectionCriteria);
    return _awaitGuarded(request);
    return Future.value([]);
  }
   */

  /// This function fetches all studies for the current user.
  /// [withParticipantActivity] includes additional participant activity with all columns of Study table => [studyWithParticipantActivityColumns]
  /// [forDashboardDisplay] includes only columns required for the Dashboard page display => [studyDisplayColumns]
  /// otherwise, all columns are fetched => [studyColumns]
  ///
  ///
  /// @return List`<Study`>
  @override
  Future<List<Study>> getUserStudies({
    bool withParticipantActivity = false,
    bool forDashboardDisplay = true,
  }) async {
    await _testDelay();
    // TODO: fix Postgres policy for proper multi-tenancy
    final columns = withParticipantActivity
        ? studyWithParticipantActivityColumns
        : forDashboardDisplay
        ? studyDisplayColumns
        : studyColumns;
    final request = getAll<Study>(selectedColumns: columns);
    return _awaitGuarded(request);
  }

  @override
  Future<Study> fetchStudy(
    StudyID studyId, {
    bool withParticipantActivity = true,
  }) async {
    await _testDelay();
    final columns = withParticipantActivity
        ? studyWithParticipantActivityColumns
        : studyColumns;
    final request = getById<Study>(studyId, selectedColumns: columns);
    return _awaitGuarded(
      request,
      onError: {
        PostgrestErrorCodes.isNotSingleItem: (e) =>
            throw StudyNotFoundException(),
      },
    );
  }

  @override
  Future<void> deleteStudy(Study study) async {
    await _testDelay();

    // Some environments still have study foreign keys without ON DELETE CASCADE.
    // Delete child rows explicitly so study deletion works there too.
    await _deleteStudyDependents(study.id);
    await study.delete();
  }

  Future<void> _deleteStudyDependents(StudyID studyId) async {
    final subjectRows = await supabaseClient
        .from(StudySubject.tableName)
        .select('id')
        .eq('study_id', studyId);
    final subjectIds = subjectRows.map((row) => row['id'] as String).toList();

    if (subjectIds.isNotEmpty) {
      await supabaseClient
          .from(SubjectProgress.tableName)
          .delete()
          .inFilter('subject_id', subjectIds);
    }

    await supabaseClient
        .from(StudySubject.tableName)
        .delete()
        .eq('study_id', studyId);
    await supabaseClient
        .from(StudyInvite.tableName)
        .delete()
        .eq('study_id', studyId);
    await supabaseClient
        .from(StudyFitbitCredentials.tableName)
        .delete()
        .eq('study_id', studyId);
    await supabaseClient.from(Repo.tableName).delete().eq('study_id', studyId);
  }

  @override
  Future<Study> saveStudy(Study study) async {
    await _testDelay();
    // Chain a fetch request to make sure we return a complete and updated study
    final request = study.save().then((study) => fetchStudy(study.id));
    return _awaitGuarded<Study>(request);
  }

  @override
  Future<StudyInvite> fetchStudyInvite(String code) async {
    final cleanCode = code.trim().toLowerCase();
    await _testDelay();
    final request = getByColumn<StudyInvite>('code', cleanCode);
    return _awaitGuarded(
      request,
      onError: {
        PostgrestErrorCodes.isNotSingleItem: (e) =>
            throw StudyInviteNotFoundException(),
      },
    );
  }

  @override
  Future<List<StudyInvite>> fetchStudyInvitesPage(
    StudyID studyId, {
    required int offset,
    required int limit,
    String? query,
    InviteCodeFilters filters = const InviteCodeFilters(),
    InviteCodesSortColumn sortBy = InviteCodesSortColumn.code,
    bool ascending = true,
  }) async {
    await _testDelay();
    final normalizedFilters = filters.normalized();
    final request = _applyInviteCodeFilters(
      supabaseClient
          .from(StudyInvite.tableName)
          .select('*,study_invite_participant_count'),
      studyId: studyId,
      query: query,
      filters: normalizedFilters,
    );
    final response = await _awaitGuarded(
      _applyInviteCodeSorting(
        request,
        sortBy: sortBy,
        ascending: ascending,
      ).range(offset, offset + limit - 1),
    );
    return deserializeList<StudyInvite>(response);
  }

  @override
  Future<int> countStudyInvites(
    StudyID studyId, {
    String? query,
    InviteCodeFilters filters = const InviteCodeFilters(),
  }) async {
    await _testDelay();
    final normalizedFilters = filters.normalized();
    final response = await _awaitGuarded(
      _applyInviteCodeFilters(
        supabaseClient.from(StudyInvite.tableName).select(),
        studyId: studyId,
        query: query,
        filters: normalizedFilters,
      ).count(),
    );
    return response.count;
  }

  @override
  Future<Study> fetchStudyFromInvite(String code) async {
    final cleanCode = code.trim().toLowerCase();
    await _testDelay();
    try {
      final request = await executeRpc(
        'get_study_record_from_invite',
        params: {'invite_code': cleanCode},
      );
      return deserializeObject<Study>(request);
    } catch (e) {
      throw StudyInviteNotFoundException();
    }
  }

  String? _trimmedOrNull(String? value) {
    final trimmed = value?.trim();
    return trimmed == null || trimmed.isEmpty ? null : trimmed;
  }

  PostgrestTransformBuilder<PostgrestList> _applyInviteCodeSorting(
    PostgrestTransformBuilder<PostgrestList> request, {
    required InviteCodesSortColumn sortBy,
    required bool ascending,
  }) {
    return switch (sortBy) {
      InviteCodesSortColumn.code => request.order('code', ascending: ascending),
      InviteCodesSortColumn.enrolled =>
        request
            .order('study_invite_participant_count', ascending: ascending)
            .order('code', ascending: true),
      InviteCodesSortColumn.createdAt => request.order(
        'created_at',
        ascending: ascending,
      ),
      InviteCodesSortColumn.updatedAt => request.order(
        'updated_at',
        ascending: ascending,
      ),
    };
  }

  PostgrestTransformBuilder<PostgrestList> _applyInviteCodeFilters(
    PostgrestFilterBuilder<PostgrestList> request, {
    required StudyID studyId,
    required String? query,
    required InviteCodeFilters filters,
  }) {
    PostgrestFilterBuilder<PostgrestList> filtered = request.eq(
      'study_id',
      studyId,
    );

    final trimmedQuery = _trimmedOrNull(query);
    if (trimmedQuery != null) {
      filtered = filtered.ilike('code', '%$trimmedQuery%');
    }

    switch (filters.enrolled) {
      case InviteCodeEnrolledFilter.all:
        break;
      case InviteCodeEnrolledFilter.unused:
        filtered = filtered.eq('study_invite_participant_count', 0);
      case InviteCodeEnrolledFilter.used:
        filtered = filtered.gt('study_invite_participant_count', 0);
    }

    if (filters.enrolledMin != null) {
      filtered = filtered.gte(
        'study_invite_participant_count',
        filters.enrolledMin!,
      );
    }
    if (filters.enrolledMax != null) {
      filtered = filtered.lte(
        'study_invite_participant_count',
        filters.enrolledMax!,
      );
    }

    switch (filters.intervention) {
      case InviteCodeInterventionFilter.all:
        break;
      case InviteCodeInterventionFilter.defaultAssignment:
        filtered = filtered.or(
          'preselected_intervention_ids.is.null,preselected_intervention_ids.eq.{}',
        );
      case InviteCodeInterventionFilter.interventionA:
        filtered = filtered.not('preselected_intervention_ids->0', 'is', null);
      case InviteCodeInterventionFilter.interventionB:
        filtered = filtered.not('preselected_intervention_ids->1', 'is', null);
    }

    return filtered;
  }

  @override
  Future<StudyInvite> saveStudyInvite(StudyInvite invite) async {
    await _testDelay();
    final request = invite.save(); // upsert will override existing record
    return _awaitGuarded<StudyInvite>(request);
  }

  @override
  Future<void> deleteStudyInvite(StudyInvite invite) async {
    await _testDelay();
    // Delegate to [SupabaseObjectMethods]
    final request = invite.delete(); // upsert will override existing record
    return _awaitGuarded<void>(request);
  }

  @override
  Future<void> deleteStudyInvites(StudyID studyId) async {
    await _testDelay();
    try {
      await supabaseClient
          .from(StudyInvite.tableName)
          .delete()
          .eq('study_id', studyId);
    } on PostgrestException catch (error) {
      throw SupabaseQueryError(
        statusCode: error.code,
        message: error.message,
        details: error.details,
      );
    }
  }

  @override
  Future<AppConfig> fetchAppConfig() {
    final request = AppConfig.getAppConfig();
    return _awaitGuarded(request);
  }

  @override
  Future<StudyUUser> fetchUser(String userId) async {
    await _testDelay();
    final request = getById<StudyUUser>(userId);
    return _awaitGuarded(
      request,
      onError: {
        PostgrestErrorCodes.isNotSingleItem: (e) =>
            throw UserNotFoundException(),
      },
    );
  }

  @override
  Future<StudyUUser> saveUser(StudyUUser user) async {
    await _testDelay();
    final request = user.save();
    return _awaitGuarded<StudyUUser>(request);
  }

  @override
  Future<StudyFitbitCredentials> saveStudyFitbitCredentials(
    StudyFitbitCredentials credentials,
  ) async {
    await _testDelay();
    final request = credentials.save();
    return _awaitGuarded<StudyFitbitCredentials>(request);
  }

  @override
  Future<StudyFitbitCredentials> fetchStudyFitbitCredentials(
    StudyID studyId,
  ) async {
    await _testDelay();
    final request = getById<StudyFitbitCredentials>(studyId);
    return _awaitGuarded(
      request,
      onError: {
        PostgrestErrorCodes.isNotSingleItem: (e) =>
            throw StudyNotFoundException(),
      },
    );
  }

  @override
  Future<void> deleteStudyFitbitCredentials(
    StudyFitbitCredentials credentials,
  ) async {
    await _testDelay();
    final request = credentials.delete();
    return _awaitGuarded<void>(request);
  }

  /// Helper that tries to complete the given Supabase query [future] while
  /// dispatching errors to the registered [onError] handlers.
  ///
  /// [onError] handlers may resolve the error directly or re-raise a
  /// domain-specific exception that bubbles up to the data layer.
  ///
  /// Raises a generic [APIException] for errors that cannot be handled.
  Future<T> _awaitGuarded<T>(
    Future<T> future, {
    Map<String, SupabaseQueryExceptionHandler>? onError,
  }) async {
    try {
      final result = await future;
      return result;
    } on SupabaseQueryError catch (e) {
      if (onError == null ||
          onError[e.statusCode] == null ||
          e.statusCode == null) {
        throw _apiException(error: e);
      }
      final errorHandler = onError[e.statusCode]!;
      errorHandler(e);
    } catch (e) {
      throw _apiException(error: e);
    }
    throw _apiException();
  }

  APIException _apiException({Object? error}) {
    if (error != null && error is SupabaseQueryError) {
      debugLog("Supabase Exception encountered");
      debugLog(error.statusCode.toString());
      debugLog(error.details.toString());
      debugLog(error.message);
    } else if (error != null) {
      debugLog("Unknown exception encountered");
      debugLog(error.toString());
    } else {
      debugLog("Unknown exception encountered. No error provided.");
    }
    return APIException();
  }

  Future<void> _testDelay() async {
    await Future.delayed(
      Duration(milliseconds: testDelayMilliseconds),
      () => null,
    );
  }
}

@riverpod
StudyUApiClient apiClient(Ref ref) =>
    StudyUApiClient(supabaseClient: ref.watch(supabaseClientProvider));
