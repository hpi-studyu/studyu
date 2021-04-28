import 'package:studyou_core/core.dart';
import 'package:studyou_core/env.dart' as env;

Future<Study> fetchStudySchema(String studyId) async => SupabaseQuery.getById<Study>(studyId);

Future<List<StudySubject>> fetchSubjects(String studyId) async =>
    SupabaseQuery.extractSupabaseList<StudySubject>(await env.client
        .from(StudySubject.tableName)
        .select('*,study(*),subject_progress(*)')
        .eq('studyId', studyId)
        .execute());
