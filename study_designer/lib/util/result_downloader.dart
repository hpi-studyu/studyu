import 'package:studyou_core/models/models.dart';
import 'package:studyou_core/models/study_results/study_result.dart';
import 'package:studyou_core/queries/queries.dart';

class ResultDownloader {
  static const participantHeader = 'participant';

  ParseStudy study;

  ResultDownloader(this.study);

  Future<void> loadDetails() async {
    study = (await StudyQueries.getStudyWithDetails(study)).results.first;
  }

  List<StudyResult> availableResults() => study.studyDetails.results;

  Future<List<ParseUserStudy>> loadAllInstances() async {
    final response = await StudyQueries.getUserStudiesFor(study);
    return response.results.cast<ParseUserStudy>();
  }

  List<List<dynamic>> getResultsFor(List<ParseUserStudy> instances, {StudyResult result}) {
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
