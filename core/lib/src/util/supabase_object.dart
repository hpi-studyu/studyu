import 'package:studyu_core/src/env/env.dart' as env;
import 'package:studyu_core/src/models/tables/app_config.dart';
import 'package:studyu_core/src/models/tables/repo.dart';
import 'package:studyu_core/src/models/tables/study.dart';
import 'package:studyu_core/src/models/tables/study_invite.dart';
import 'package:studyu_core/src/models/tables/study_subject.dart';
import 'package:studyu_core/src/models/tables/subject_progress.dart';
import 'package:supabase/supabase.dart';

abstract class SupabaseObject {
  Map<String, dynamic> get primaryKeys;

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
      default:
        print('$T is not a supported Supabase type');
        throw TypeError();
    }
  }

  Future<T> delete() async => SupabaseQuery.extractSupabaseSingleRow<T>(
        await env.client.from(tableName(T)).delete().primaryKeys(primaryKeys).single().select<Map<String, dynamic>>(),
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
        await env.client.from(tableName(T)).select(selectedColumns.join(',')).eq('id', id).single()
            as Map<String, dynamic>,
      );
    } catch (error, stacktrace) {
      catchSupabaseException(error, stacktrace);
      rethrow;
    }
  }

  static Future<List<T>> batchUpsert<T extends SupabaseObject>(List<Map<String, dynamic>> batchJson) async =>
      SupabaseQuery.extractSupabaseList<T>(await env.client.from(tableName(T)).upsert(batchJson).select());

  static List<T> extractSupabaseList<T extends SupabaseObject>(List<Map<String, dynamic>> response) {
    return List<T>.from(
      List<Map<String, dynamic>>.from(response).map((json) => SupabaseObjectFunctions.fromJson<T>(json)),
    );
  }

  static T extractSupabaseSingleRow<T extends SupabaseObject>(Map<String, dynamic> response) {
    return SupabaseObjectFunctions.fromJson<T>(response);
  }

  static void catchSupabaseException(Object error, StackTrace stacktrace) {
    if (error is PostgrestException) {
      print('Message: ${error.message}');
      print('Hint: ${error.hint}');
      print('Details: ${error.details}');
      print('Code: ${error.code}');
      print('Stacktrace: $stacktrace');
      throw error;
    } else {
      print('Caught Supabase Error: $error');
      print('Stacktrace: $stacktrace');
      throw error;
    }
  }
}

extension PrimaryKeyFilterBuilder on PostgrestFilterBuilder {
  PostgrestFilterBuilder primaryKeys(Map<String, dynamic> primaryKeys) {
    var primaryKeyFilter = this;
    primaryKeys.forEach((columnKey, value) {
      primaryKeyFilter = primaryKeyFilter.eq(columnKey, value);
    });
    return primaryKeyFilter;
  }
}
