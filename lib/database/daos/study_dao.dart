import 'package:parse_server_sdk/parse_server_sdk.dart';

import '../models/models.dart';

const filename = 'assets/studies/scratch.xml';

class StudyDao {
  Future<List<Study>> getAllStudies() async {
    final response = await Study().getAll();
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
}
