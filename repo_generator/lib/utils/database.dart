import 'package:studyu_core/core.dart';

Future<Study> fetchStudySchema(String studyId) async => SupabaseQuery.getById<Study>(studyId);

Future<String> fetchSubjects(String studyId) async => Study.fetchResultsCSVTable(studyId);
