import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:studyu_core/core.dart';
import 'package:studyu_designer_v2/domain/study.dart';
import 'package:studyu_designer_v2/domain/study_subject.dart';
import 'package:studyu_designer_v2/repositories/supabase_client.dart';
import 'package:studyu_designer_v2/utils/debug_print.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

part 'api_client.g.dart';

abstract class StudyUApi {
  Future<Study> saveStudy(Study study);
  Future<Study> fetchStudy(StudyID studyId);
  Future<List<Study>> getUserStudies();
  Future<void> deleteStudy(Study study);
  Future<StudyInvite> saveStudyInvite(StudyInvite invite);
  Future<StudyInvite> fetchStudyInvite(String code);
  Future<void> deleteStudyInvite(StudyInvite invite);
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
    'study_participant_count',
    'study_ended_count',
    'active_subject_count',
    'study_missed_days',
  ];

  static final studyDisplayColumns = ['*'];

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
  /// @return List<Study>
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
    // Delegate to [SupabaseObjectMethods]
    // TODO: proper error handling here (encountered so far: 409, 406)
    await study.delete();
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
    await _testDelay();
    final request = getByColumn<StudyInvite>('code', code);
    return _awaitGuarded(
      request,
      onError: {
        PostgrestErrorCodes.isNotSingleItem: (e) =>
            throw StudyInviteNotFoundException(),
      },
    );
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
  Future<AppConfig> fetchAppConfig() async {
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
      if (onError == null || e.statusCode == null) {
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
StudyUApiClient apiClient(ApiClientRef ref) => StudyUApiClient(
      supabaseClient: ref.watch(supabaseClientProvider),
    );
