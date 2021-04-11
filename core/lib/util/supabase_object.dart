import 'package:postgrest/postgrest.dart';
import 'package:supabase/supabase.dart';

const supabaseUrl = 'https://urrbcqpjcgokldetihiw.supabase.co';
const supabaseAnonKey =
    'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJyb2xlIjoiYW5vbiIsImlhdCI6MTYxNzUzMDYwMSwiZXhwIjoxOTMzMTA2NjAxfQ.T-QhpPisubwjOn3P1Gj3DV-2Mb_ztzvLwiVYWrGFvVA';

abstract class SupabaseObject<T> {
  String tableName;
  String id;

  Map<String, dynamic> toJson();

  T fromJson(Map<String, dynamic> json);
}

abstract class SupabaseObjectFunctions<T extends SupabaseObject> implements SupabaseObject<T> {
  final client = SupabaseClient(supabaseUrl, supabaseAnonKey);

  Future<List<T>> getAll({List<String> selectedColumns = const ['*']}) async =>
      extractSupabaseList(await client.from(tableName).select(selectedColumns.join(',')).execute());

  Future<T> getById(String id) async =>
      extractSupabaseSingleRow(await client.from(tableName).select().eq('id', id).single().execute());

  Future<T> delete() async =>
      extractSupabaseSingleRow(await client.from(tableName).delete().eq('id', id).single().execute());

  Future<T> save() async {
    return extractSupabaseList(await client.from(tableName).insert(toJson(), upsert: true).execute()).single;
  }

  List<T> extractSupabaseList(PostgrestResponse response) {
    catchPostgrestError(response.error);
    return List<T>.from(List<Map<String, dynamic>>.from(response.data as List).map((json) => fromJson(json)));
  }

  T extractSupabaseSingleRow(PostgrestResponse response) {
    catchPostgrestError(response.error);
    return fromJson(response.data as Map<String, dynamic>);
  }

  void catchPostgrestError(PostgrestError error) {
    if (error != null) {
      print('Error: ${error.message}');
      // ignore: only_throw_errors
      throw error;
    }
  }
}
