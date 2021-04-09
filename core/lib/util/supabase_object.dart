import 'package:postgrest/postgrest.dart';
import 'package:supabase/supabase.dart';

const supabaseUrl = 'https://urrbcqpjcgokldetihiw.supabase.co';
const supabaseAnonKey =
    'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJyb2xlIjoiYW5vbiIsImlhdCI6MTYxNzUzMDYwMSwiZXhwIjoxOTMzMTA2NjAxfQ.T-QhpPisubwjOn3P1Gj3DV-2Mb_ztzvLwiVYWrGFvVA';

abstract class SupabaseObject {
  String tableName;
  String id;
}

abstract class SupabaseObjectFunctions implements SupabaseObject {
  Map<String, dynamic> toJson();

  final client = SupabaseClient(supabaseUrl, supabaseAnonKey);

  Future<PostgrestResponse> getAll({List<String> selectedColumns = const ['*']}) async =>
      client.from(tableName).select(selectedColumns.join(',')).execute();

  Future<PostgrestResponse> getById(String id) async => client.from(tableName).select().eq('id', id).execute();

  Future<PostgrestResponse> delete() async => client.from(tableName).delete().eq('id', id).execute();

  Future<PostgrestResponse> save() async => client.from(tableName).insert(toJson(), upsert: true).execute();
}
