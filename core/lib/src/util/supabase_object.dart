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

abstract class SupabaseObjectFunctions<T extends SupabaseObject> implements SupabaseObject {
  static T fromJson<T extends SupabaseObject>(Map<String, dynamic> json) => switch (T) {
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
        await env.client.from(tableName(T)).delete().primaryKeys(primaryKeys).select().single(),
      );

  Future<T> save() async {
    return SupabaseQuery.extractSupabaseList<T>(await env.client.from(tableName(T)).upsert(this.toJson()).select())
        .single;
  }
}

// ignore: avoid_classes_with_only_static_members
class SupabaseQuery {
  static Future<List<T>> getAll<T extends SupabaseObject>({List<String> selectedColumns = const ['*']}) async {
    try {
      return extractSupabaseList(await env.client.from(tableName(T)).select(selectedColumns.join(',')));
    } catch (error, stacktrace) {
      catchSupabaseException(error, stacktrace);
      rethrow;
    }
  }

  static Future<T> getById<T extends SupabaseObject>(String id, {List<String> selectedColumns = const ['*']}) async {
    try {
      return extractSupabaseSingleRow(
        await env.client.from(tableName(T)).select(selectedColumns.join(',')).eq('id', id).single(),
      );
    } catch (error, stacktrace) {
      catchSupabaseException(error, stacktrace);
      rethrow;
    }
  }

  static Future<List<T>> batchUpsert<T extends SupabaseObject>(List<Map<String, dynamic>> batchJson) async {
    try {
      return SupabaseQuery.extractSupabaseList<T>(await env.client.from(tableName(T)).upsert(batchJson).select());
    } catch (error, stacktrace) {
      catchSupabaseException(error, stacktrace);
      rethrow;
    }
  }

  static List<T> extractSupabaseList<T extends SupabaseObject>(List<Map<String, dynamic>> response) {
    return List<T>.from(
      List<Map<String, dynamic>>.from(response).map((json) => SupabaseObjectFunctions.fromJson<T>(json)),
    );
  }

  static T extractSupabaseSingleRow<T extends SupabaseObject>(Map<String, dynamic> response) {
    return SupabaseObjectFunctions.fromJson<T>(response);
  }

  static void catchSupabaseException(Object error, StackTrace stacktrace) {
    Analytics.captureException(error, stackTrace: stacktrace);
    if (error is PostgrestException) {
      StudyULogger.fatal('Message: ${error.message}');
      StudyULogger.fatal('Hint: ${error.hint}');
      StudyULogger.fatal('Details: ${error.details}');
      StudyULogger.fatal('Code: ${error.code}');
      StudyULogger.fatal('Stacktrace: $stacktrace');
      throw error;
    } else if (error is SocketException) {
      StudyULogger.info("App is suspected to be offline");
      throw error;
    } else {
      StudyULogger.fatal('Caught Supabase Error: $error');
      StudyULogger.fatal('Stacktrace: $stacktrace');
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
