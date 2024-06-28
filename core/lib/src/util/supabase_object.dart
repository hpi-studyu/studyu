import 'dart:io';

import 'package:studyu_core/core.dart';
import 'package:studyu_core/src/env/env.dart' as env;
import 'package:supabase/supabase.dart';

abstract class SupabaseObject {
  Map<String, Object> get primaryKeys;

  Map<String, dynamic> toJson();
}

String tableName(Type cls) => switch (cls) {
      == Study => Study.tableName,
      == StudySubject => StudySubject.tableName,
      == SubjectProgress => SubjectProgress.tableName,
      == AppConfig => AppConfig.tableName,
      == Repo => Repo.tableName,
      == StudyInvite => StudyInvite.tableName,
      == StudyUUser => StudyUUser.tableName,
      _ => throw ArgumentError('$cls is not a supported Supabase type'),
    };

abstract class SupabaseObjectFunctions<T extends SupabaseObject>
    implements SupabaseObject {
  static T fromJson<T extends SupabaseObject>(Map<String, dynamic> json) =>
      switch (T) {
        == Study => Study.fromJson(json) as T,
        == StudySubject => StudySubject.fromJson(json) as T,
        == SubjectProgress => SubjectProgress.fromJson(json) as T,
        == AppConfig => AppConfig.fromJson(json) as T,
        == Repo => Repo.fromJson(json) as T,
        == StudyInvite => StudyInvite.fromJson(json) as T,
        == StudyUUser => StudyUUser.fromJson(json) as T,
        _ => throw ArgumentError('$T is not a supported Supabase type'),
      };

  Future<T> delete() async => SupabaseQuery.extractSupabaseSingleRow<T>(
        await env.client
            .from(tableName(T))
            .delete()
            .primaryKeys(primaryKeys)
            .select()
            .single(),
      );

  /// Save the object to the database.
  /// By default, this will upsert the object, i.e. insert it if it does not exist, or update it if it does.
  /// If [onlyUpdate] is set to true, the object has to exist in the database, otherwise the result will be empty.
  Future<T> save({bool onlyUpdate = false}) async {
    final tableQuery = env.client.from(tableName(T));
    PostgrestFilterBuilder query;
    if (onlyUpdate) {
      query = tableQuery.upsert(this.toJson());
      for (final entry in primaryKeys.entries) {
        query = query.eq(entry.key, entry.value);
      }
    } else {
      query = tableQuery.upsert(this.toJson());
    }
    return SupabaseQuery.extractSupabaseList<T>(await query.select()).single;
  }
}

// ignore: avoid_classes_with_only_static_members
class SupabaseQuery {
  static Future<List<T>> getAll<T extends SupabaseObject>({
    List<String> selectedColumns = const ['*'],
  }) async {
    try {
      return extractSupabaseList(
        await env.client.from(tableName(T)).select(selectedColumns.join(',')),
      );
    } catch (error, stacktrace) {
      catchSupabaseException(error, stacktrace);
      rethrow;
    }
  }

  static Future<T> getById<T extends SupabaseObject>(
    String id, {
    List<String> selectedColumns = const ['*'],
  }) async {
    try {
      return extractSupabaseSingleRow(
        await env.client
            .from(tableName(T))
            .select(selectedColumns.join(','))
            .eq('id', id)
            .single(),
      );
    } catch (error, stacktrace) {
      catchSupabaseException(error, stacktrace);
      rethrow;
    }
  }

  static Future<List<T>> batchUpsert<T extends SupabaseObject>(
    List<Map<String, dynamic>> batchJson,
  ) async {
    try {
      return SupabaseQuery.extractSupabaseList<T>(
        await env.client.from(tableName(T)).upsert(batchJson).select(),
      );
    } catch (error, stacktrace) {
      catchSupabaseException(error, stacktrace);
      rethrow;
    }
  }

  /// Extracts a list of SupabaseObjects from a response.
  /// If some records could not be extracted, [ExtractionFailedException] is
  /// thrown containing the extracted records and the faulty records.
  static List<T> extractSupabaseList<T extends SupabaseObject>(
    List<Map<String, dynamic>> response,
  ) {
    final extracted = <T>[];
    final notExtracted = <JsonWithError>[];
    for (final json in response) {
      try {
        extracted.add(SupabaseObjectFunctions.fromJson<T>(json));
        // ignore: avoid_catching_errors
      } on ArgumentError catch (error) {
        // We are catching ArgumentError because unknown enums throw an ArgumentError
        // and UnknownJsonTypeError is a subclass of ArgumentError
        notExtracted.add(JsonWithError(json, error));
      }
    }
    if (notExtracted.isNotEmpty) {
      // If some records could not be extracted, we throw an exception
      // with the extracted records and the faulty records
      print("Failed to extract: $notExtracted");
      throw ExtractionFailedException(extracted, notExtracted);
    }
    return extracted;
  }

  static T extractSupabaseSingleRow<T extends SupabaseObject>(
    Map<String, dynamic> response,
  ) {
    return SupabaseObjectFunctions.fromJson<T>(response);
  }

  static void catchSupabaseException(Object error, StackTrace stacktrace) {
    StudyUDiagnostics.captureException(error, stackTrace: stacktrace);
    if (error is PostgrestException) {
      StudyULogger.fatal(
        'Caught Postgrest Error: $error\nStacktrace: $stacktrace',
      );
      throw error;
    } else if (error is SocketException) {
      // StudyULogger.info("App is suspected to be offline");
      throw error;
    } else {
      StudyULogger.fatal('Caught Supabase Error: $error');
      throw error;
    }
  }
}

extension PrimaryKeyFilterBuilder on PostgrestFilterBuilder {
  PostgrestFilterBuilder primaryKeys(Map<String, Object> primaryKeys) {
    var primaryKeyFilter = this;
    primaryKeys.forEach((columnKey, value) {
      primaryKeyFilter = primaryKeyFilter.eq(columnKey, value);
    });
    return primaryKeyFilter;
  }
}

sealed class ExtractionResult<T> {
  final List<T> extracted;

  ExtractionResult(this.extracted);
}

class ExtractionSuccess<T> extends ExtractionResult<T> {
  ExtractionSuccess(super.extracted);
}

class ExtractionFailedException<T> extends ExtractionResult<T>
    implements Exception {
  final List<JsonWithError> notExtracted;

  ExtractionFailedException(super.extracted, this.notExtracted);
}

class JsonWithError {
  final Map<String, dynamic> json;
  final Object error;

  JsonWithError(this.json, this.error);
}
