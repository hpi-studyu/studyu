import 'package:studyou_core/core.dart';
import 'package:supabase/supabase.dart';

class ResultDownloader {
  static const participantHeader = 'participant';

  Study study;
  SupabaseClient client;

  ResultDownloader({this.client, this.study});

  List<StudyResult> availableResults() => study.results;

  List<List<dynamic>> getResultsFor(List<StudySubject> instances, {StudyResult result}) {
    final header = [participantHeader, ...result.getHeaders(study)];
    return [
      header,
      ...instances.map((e) => [e.userId, ...result.getValues(e)])
    ];
  }

  Future<List<List<dynamic>>> loadResultsFor(StudyResult result) async {
    final instances = await StudySubject.getUserStudiesFor(study);
    return getResultsFor(instances, result: result);
  }

  Future<Map<StudyResult, List<List<dynamic>>>> loadAllResults() async {
    final instances = await StudySubject.getUserStudiesFor(study);
    final results = <StudyResult, List<List<dynamic>>>{};
    for (final result in availableResults()) {
      results[result] = getResultsFor(instances, result: result);
    }
    return results;
  }
}
