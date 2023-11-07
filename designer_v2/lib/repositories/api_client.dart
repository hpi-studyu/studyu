import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart' as riverpod;
import 'package:studyu_core/core.dart';
import 'package:studyu_designer_v2/domain/study.dart';
import 'package:studyu_designer_v2/domain/study_subject.dart';
import 'package:studyu_designer_v2/repositories/supabase_client.dart';
import 'package:studyu_designer_v2/utils/debug_print.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

abstract class StudyUApi {
  Future<Study> saveStudy(Study study);
  Future<Study> fetchStudy(StudyID studyId);
  Future<List<Study>> getUserStudies();
  Future<void> deleteStudy(Study study);
  Future<StudyInvite> saveStudyInvite(StudyInvite invite);
  Future<StudyInvite> fetchStudyInvite(String code);
  Future<void> deleteStudyInvite(StudyInvite invite);
  Future<List<StudySubject>> deleteParticipants(Study study, List<StudySubject> participants);
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

class StudyUApiClient extends SupabaseClientDependant with SupabaseQueryMixin implements StudyUApi {
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

  static final studyWithParticipantActivityColumns = [
    ...studyColumns,
    'study_subject!study_subject_studyId_fkey(*)',
    'study_progress_export(*)',
  ];

  final int testDelayMilliseconds;

  @override
  Future<List<StudySubject>> deleteParticipants(Study study, List<StudySubject> participants) async {
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

  @override
  Future<List<Study>> getUserStudies({withParticipantActivity = true}) async {
    await _testDelay();
    // TODO: fix Postgres policy for proper multi-tenancy
    final columns = (withParticipantActivity) ? studyWithParticipantActivityColumns : studyColumns;
    final request = getAll<Study>(selectedColumns: columns);
    return _awaitGuarded(request);
  }

  @override
  Future<Study> fetchStudy(StudyID studyId, {withParticipantActivity = true}) async {
    await _testDelay();
    final columns = (withParticipantActivity) ? studyWithParticipantActivityColumns : studyColumns;
    final request = getById<Study>(studyId, selectedColumns: columns);
    return _awaitGuarded(request, onError: {
      HttpStatus.notAcceptable: (e) => throw StudyNotFoundException(),
      HttpStatus.notFound: (e) => throw StudyNotFoundException(),
    });
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
    return _awaitGuarded(request, onError: {
      HttpStatus.notAcceptable: (e) => throw StudyInviteNotFoundException(),
      HttpStatus.notFound: (e) => throw StudyInviteNotFoundException(),
    });
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
    return _awaitGuarded(request, onError: {
      HttpStatus.notAcceptable: (e) => throw UserNotFoundException(),
      HttpStatus.notFound: (e) => throw UserNotFoundException(),
    });
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
  Future<T> _awaitGuarded<T>(Future<T> future, {Map<int, SupabaseQueryExceptionHandler>? onError}) async {
    try {
      final result = await future;
      return result;
    } on SupabaseQueryError catch (e) {
      if (onError == null) {
        throw _apiException(error: e);
      }
      if (e.statusCode == null || !onError.containsKey(int.parse(e.statusCode!))) {
        throw _apiException(error: e);
      }
      final errorHandler = onError[int.parse(e.statusCode!)]!;
      errorHandler(e);
    }
    throw _apiException();
  }

  _apiException({SupabaseQueryError? error}) {
    if (error != null) {
      debugLog("Supabase Exception encountered");
      debugLog(error.statusCode.toString());
      debugLog(error.details);
      debugLog(error.message);
    } else {
      debugLog("Unknown exception encountered");
    }
    return APIException();
  }

  _testDelay() async {
    await Future.delayed(Duration(milliseconds: testDelayMilliseconds), () => null);
  }
}

final apiClientProvider = riverpod.Provider<StudyUApi>((ref) => StudyUApiClient(
      supabaseClient: ref.watch(supabaseClientProvider),
    ));
