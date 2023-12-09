import 'dart:io';

import 'package:studyu_core/core.dart';
import 'package:studyu_core/src/env/env.dart' as env;
import 'package:supabase/supabase.dart';

abstract class SupabaseObject {
  Map<String, Object> get primaryKeys;

  Map<String, dynamic> toJson();
}

String tableName(Type cls) {
  switch (cls) {
    case Study:
      return Study.tableName;
    case StudySubject:
      return StudySubject.tableName;
    case SubjectProgress:
      return SubjectProgress.tableName;
    case AppConfig:
      return AppConfig.tableName;
    case Repo:
      return Repo.tableName;
    case StudyInvite:
      return StudyInvite.tableName;
    case StudyUUser:
      return StudyUUser.tableName;
    default:
      print('$cls is not a supported Supabase type');
      throw TypeError();
  }
}

abstract class SupabaseObjectFunctions<T extends SupabaseObject> implements SupabaseObject {
  static T fromJson<T extends SupabaseObject>(Map<String, dynamic> json) {
    switch (T) {
      case Study:
        return Study.fromJson(json) as T;
      case StudySubject:
        return StudySubject.fromJson(json) as T;
      case SubjectProgress:
        return SubjectProgress.fromJson(json) as T;
      case AppConfig:
        return AppConfig.fromJson(json) as T;
      case Repo:
        return Repo.fromJson(json) as T;
      case StudyInvite:
        return StudyInvite.fromJson(json) as T;
      case StudyUUser:
        return StudyUUser.fromJson(json) as T;
      default:
        print('$T is not a supported Supabase type');
        throw TypeError();
    }
  }

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
