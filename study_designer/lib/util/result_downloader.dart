import 'package:studyou_core/models/models.dart';
import 'package:studyou_core/models/study_results/study_result.dart';
import 'package:supabase/supabase.dart';

class ResultDownloader {
  static const participantHeader = 'participant';

  Study study;
  SupabaseClient client;

  ResultDownloader({this.client, this.study});

  List<StudyResult> availableResults() => study.results;

  Future<List<UserStudy>> loadAllInstances() async {
    final response = await UserStudy().getUserStudiesFor(study);
    return (response.data as List).map((json) => UserStudy.fromJson(json as Map<String, dynamic>)).toList();
  }

  List<List<dynamic>> getResultsFor(List<UserStudy> instances, {StudyResult result}) {
    final header = [participantHeader, ...result.getHeaders(study)];
    return [
      header,
      ...instances.map((e) => [e.userId, ...result.getValues(e)])
    ];
  }

  Future<List<List<dynamic>>> loadResultsFor(StudyResult result) async {
    final instances = await loadAllInstances();
    return getResultsFor(instances, result: result);
  }

  Future<Map<StudyResult, List<List<dynamic>>>> loadAllResults() async {
    final instances = await loadAllInstances();
    final results = <StudyResult, List<List<dynamic>>>{};
    for (final result in availableResults()) {
      results[result] = getResultsFor(instances, result: result);
    }
    return results;
  }
}
