import 'package:parse_server_sdk/parse_server_sdk.dart';

import '../models/models.dart';
import '../models/questionnaire/eligibility.dart';

const filename = 'assets/studies/scratch.xml';

class StudyDao {
  Future<List<Study>> getAllStudies() async {
    var response = await Study().getAll();
    if (response.success) {
      return response.results.map((study) => study is Study ? study : null).toList();
    }
    return [];
  }

  Future<Study> getStudyWithStudyDetails(Study study) async {
    var detailedStudy = study;
    if (study.studyDetails != null && study.studyDetails.createdAt == null) {
      final builder = QueryBuilder<Study>(Study())
        ..whereEqualTo('objectId', study.objectId)
        ..includeObject(['study_details']);
      detailedStudy = await builder.query().then((response) =>
              response.success ? response.results.isNotEmpty ? response.results.first as Study : null : null) ??
          study;
    }
    return detailedStudy;
  }

  Future<Eligibility> getEligibility(Study study) async {
    //TODO add to study
    var response = await Eligibility().getObject(null);
    if (response.success && response.results.isNotEmpty) {
      return response.results.first is Eligibility ? response.results.first : null;
    }
    return null;
  }
}
