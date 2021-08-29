import 'package:supabase/supabase.dart';

import '../env/env.dart' as env;
import '../models/tables/app_config.dart';
import '../models/tables/repo.dart';
import '../models/tables/study.dart';
import '../models/tables/study_invite.dart';
import '../models/tables/study_subject.dart';
import '../models/tables/subject_progress.dart';

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
      await env.client.from(tableName(T)).delete().primaryKeys(primaryKeys).single().execute());

  Future<T> save() async =>
      SupabaseQuery.extractSupabaseList<T>(await env.client.from(tableName(T)).upsert(toJson()).execute()).single;
}

class SupabaseQuery {
  static Future<List<T>> getAll<T extends SupabaseObject>({List<String> selectedColumns = const ['*']}) async =>
      extractSupabaseList(await env.client.from(tableName(T)).select(selectedColumns.join(',')).execute());

  static Future<T> getById<T extends SupabaseObject>(String id, {List<String> selectedColumns = const ['*']}) async =>
      extractSupabaseSingleRow(
          await env.client.from(tableName(T)).select(selectedColumns.join(',')).eq('id', id).single().execute());

  static Future<List<T>> batchUpsert<T extends SupabaseObject>(List<Map<String, dynamic>> batchJson) async =>
      SupabaseQuery.extractSupabaseList<T>(await env.client.from(tableName(T)).upsert(batchJson).execute());

  static List<T> extractSupabaseList<T extends SupabaseObject>(PostgrestResponse response) {
    catchPostgrestError(response);
    return List<T>.from(List<Map<String, dynamic>>.from(response.data as List)
        .map((json) => SupabaseObjectFunctions.fromJson<T>(json)));
  }

  static T extractSupabaseSingleRow<T extends SupabaseObject>(PostgrestResponse response) {
    catchPostgrestError(response);
    return SupabaseObjectFunctions.fromJson<T>(response.data as Map<String, dynamic>);
  }

  static void catchPostgrestError(PostgrestResponse response) {
    if (response.error != null) {
      print('Data: ${response.data}');
      print('Status: ${response.status}');
      print('Error: ${response.error!.message}');
      // ignore: only_throw_errors
      throw response.error!.message;
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
