import 'package:parse_server_sdk/parse_server_sdk.dart';

import '../models/models.dart';
import '../models/user_study.dart';

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
      final response = await builder.query();
      detailedStudy = response.success && response.results.isNotEmpty ? response.results.first : study;
    }
    return detailedStudy;
  }

  static Future<UserStudy> getUserStudy(String objectId) async {
    final builder = QueryBuilder<UserStudy>(UserStudy())
      ..whereEqualTo('objectId', objectId);
    return await builder.query().then((response) =>
    response.success ? response.results.isNotEmpty ? response.results.first as UserStudy : null : null);
  }
  static Future<String> saveUserStudy(UserStudy userStudy) async {
    final response = await userStudy.save();
    if (response.success) {
      return userStudy.objectId;
    }
    print('Could not save UserStudy!');
    return null;
  }
}
