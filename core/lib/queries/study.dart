import 'package:parse_server_sdk/parse_server_sdk.dart';
import 'package:studyou_core/models/models.dart';
import 'package:studyou_core/queries/user.dart';

class StudyQueries {
  static Future<ParseResponse> getStudyDetails(Study study) async {
    final builder = QueryBuilder<Study>(Study())
      ..whereEqualTo('objectId', study.objectId)
      ..includeObject(['study_details']);
    return builder.query();
  }

  static Future<StudyInstance> getUserStudy(String objectId) async {
    final builder = QueryBuilder<StudyInstance>(StudyInstance())..whereEqualTo('objectId', objectId);
    return builder
        .query()
        .then((response) => response.success && response.results.isNotEmpty ? response.results.first : null);
  }

  static Future<String> saveUserStudy(StudyInstance userStudy) async {
    final response = await userStudy.save();
    if (response.success) {
      return userStudy.objectId;
    }
    print('Could not save UserStudy!');
    return null;
  }

  static Future<List<StudyInstance>> getStudyHistory() async {
    final builder = QueryBuilder<StudyInstance>(StudyInstance())
      ..whereEqualTo(StudyInstance.keyUserId, await UserQueries.getOrCreateUser().then((user) => user.objectId));
    return builder.query().then((response) => response.success
        ? response.results
            .map<StudyInstance>((instance) => instance is StudyInstance ? instance : null)
            .where((element) => element != null)
            .toList()
        : <StudyInstance>[]);
  }
}
