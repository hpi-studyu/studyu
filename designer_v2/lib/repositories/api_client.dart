import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:studyu_core/core.dart';
import 'package:studyu_designer_v2/domain/study.dart';
import 'package:studyu_designer_v2/repositories/supabase_client.dart';
import 'package:studyu_designer_v2/utils/debug_print.dart';
import 'package:supabase/src/supabase.dart';

abstract class StudyUApi {
  Future<Study> fetchStudy(StudyID studyId);
  Future<List<Study>> getUserStudies();
  Future<void> deleteStudy(Study study);
}

typedef SupabaseQueryExceptionHandler = void Function(SupabaseQueryError error);

/// Base class for domain-specific exceptions
class APIException implements Exception {}
class StudyNotFoundException extends APIException {}

class StudyUApiClient extends SupabaseClientDependant
    with SupabaseQueryMixin implements StudyUApi  {
  StudyUApiClient({required this.supabaseClient});

  /// Reference to the [SupabaseClient] injected via Riverpod
  @override
  final SupabaseClient supabaseClient;

  @override
  Future<List<Study>> getUserStudies() async {
    // TODO: fix Postgres policy for proper multi-tenancy
    final request = getAll<Study>(
      selectedColumns: [
        '*',
        'repo(*)',
        'study_participant_count',
        'study_ended_count',
        'active_subject_count',
        'study_missed_days'
      ],
    );
    return _awaitGuarded(request);
  }

  @override
  Future<Study> fetchStudy(StudyID studyId) async {
    // uncomment to test loading states
    await Future.delayed(const Duration(seconds: 2));
    final request = getById<Study>(studyId);
    return _awaitGuarded(request, onError: {
      HttpStatus.notAcceptable: (e) => throw StudyNotFoundException(),
      HttpStatus.notFound: (e) => throw StudyNotFoundException(),
    });
    /*
    try {
      final study = await getById<Study>(studyId);
      return study;
    } on SupabaseQueryError catch (e) {
      switch (e.statusCode) {
        case HttpStatus.notAcceptable:
        case HttpStatus.notFound:
          throw StudyNotFoundException();
        default:
          throw _apiException();
      }
    } catch (_) {
      throw _apiException();
    }
     */
  }

  @override
  Future<void> deleteStudy(Study study) async {
    // Delegate to [SupabaseObjectMethods]
    // TODO: proper error handling here
    await study.delete();
  }

  /// Helper that tries to complete the given Supabase query [future] while
  /// dispatching errors to the registered [onError] handlers.
  ///
  /// [onError] handlers may resolve the error directly or re-raise a
  /// domain-specific exception that bubbles up to the data layer.
  ///
  /// Raises a generic [APIException] for errors that cannot be handled.
  Future<T> _awaitGuarded<T>(Future<T> future, {
    Map<int, SupabaseQueryExceptionHandler>? onError}) async {
    try {
      final result = await future;
      return result;
    } on SupabaseQueryError catch (e) {
      if (onError == null) {
        throw _apiException();
      }
      if (e.statusCode == null || !onError.containsKey(e.statusCode)) {
        throw _apiException();
      }
      final errorHandler = onError[e.statusCode]!;
      errorHandler(e);
    }
    throw _apiException();
  }

  _apiException() {
    debugLog("Unknown exception encountered");
    return APIException();
  }
}

final apiClientProvider = Provider<StudyUApi>((ref) => StudyUApiClient(
  supabaseClient: ref.watch(supabaseClientProvider),
));
