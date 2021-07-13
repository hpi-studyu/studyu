import 'package:studyu_core/core.dart';
import 'package:studyu_core/env.dart' as env;

Future<Study> fetchStudySchema(String studyId) async => SupabaseQuery.getById<Study>(studyId);

Future<List<dynamic>> fetchSubjects(String studyId) async {
  final res =
      await env.client.from(StudySubject.tableName).select('*,subject_progress(*)').eq('study_id', studyId).execute();
  SupabaseQuery.catchPostgrestError(res);
  return res.data;
}
