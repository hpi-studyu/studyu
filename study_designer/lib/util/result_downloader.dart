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
    var response = await StudyQueries.getUserStudiesFor(study);
    return response.results.cast<ParseUserStudy>();
  }

  List<List<dynamic>> getResultsFor(List<ParseUserStudy> instances, {StudyResult result}) {
    var header = [participantHeader, ...result.getHeaders(study)];
    return [
      header,
      ...instances.map((e) => [e.userId, ...result.getValues(e)])
    ];
  }

  Future<List<List<dynamic>>> loadResultsFor(StudyResult result) async {
    var instances = await loadAllInstances();
    return getResultsFor(instances, result: result);
  }

  Future<Map<StudyResult, List<List<dynamic>>>> loadAllResults() async {
    var instances = await loadAllInstances();
    var results = Map<StudyResult, List<List<dynamic>>>();
    for (var result in availableResults()) {
      results[result] = getResultsFor(instances, result: result);
    }
    return results;
  }
}
