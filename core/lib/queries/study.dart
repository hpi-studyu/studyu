import 'package:parse_server_sdk/parse_server_sdk.dart';
import 'package:studyou_core/models/models.dart';
import 'package:studyou_core/queries/user.dart';

class StudyQueries {
  static Future<ParseResponse> getPublishedStudies() async {
    final builder = QueryBuilder<ParseStudy>(ParseStudy())
      ..whereEqualTo('published', true)
      ..includeObject(['study_details']);
    return builder.query();
  }

  static Future<ParseResponse> getStudyWithDetails(ParseStudy study) async {
    final builder = QueryBuilder<ParseStudy>(ParseStudy())
      ..whereEqualTo('objectId', study.objectId)
      ..includeObject(['study_details']);
    return builder.query();
  }

  static Future<ParseResponse> getStudyWithDetailsByStudyId(String studyId) async {
    final builder = QueryBuilder<ParseStudy>(ParseStudy())
      ..whereEqualTo(ParseStudy.keyId, studyId)
      ..includeObject(['study_details']);
    return builder.query();
  }

  static Future<ParseUserStudy> getUserStudy(String objectId) async {
    final builder = QueryBuilder<ParseUserStudy>(ParseUserStudy())..whereEqualTo('objectId', objectId);
    return builder
        .query()
        .then((response) => response.success && response.results.isNotEmpty ? response.results.first : null);
  }

  static Future<String> saveUserStudy(ParseUserStudy userStudy) async {
    final response = await userStudy.save();
    if (response.success) {
      return userStudy.objectId;
    }
    print('Could not save UserStudy!');
    return null;
  }

  static Future<ParseResponse> getStudyHistory() async {
    final builder = QueryBuilder<ParseUserStudy>(ParseUserStudy())
      ..whereEqualTo(ParseUserStudy.keyUserId, await UserQueries.getOrCreateUser().then((user) => user.objectId));
    return builder.query();
  }
}
