import 'package:parse_server_sdk_flutter/parse_server_sdk.dart';
import 'package:studyou_core/models/models.dart';
import 'package:studyou_core/queries/user.dart';

final researcherDashboardStudyKeys = ["objectId", "study_id", "title", "description", "published", "icon_name"];

extension StudyQueries on ParseStudy {
  Future<ParseResponse> getPublishedStudies() async {
    final builder = QueryBuilder<ParseStudy>(this)..whereEqualTo('published', true);
    return builder.query();
  }

  Future<ParseResponse> getAllStudiesWith(List<String> keys) async {
    final builder = QueryBuilder<ParseStudy>(this)..keysToReturn(keys);
    return builder.query();
  }

  Future<ParseResponse> getResearcherDashboardStudies() async {
    return getAllStudiesWith(researcherDashboardStudyKeys);
  }

  Future<ParseResponse> getStudyById(String studyId) async {
    final builder = QueryBuilder<ParseStudy>(this)..whereEqualTo(ParseStudy.keyId, studyId);
    return builder.query();
  }
}

extension UserStudyQueries on ParseUserStudy {
  Future<ParseResponse> getUserStudiesFor(ParseStudy study) async {
    final builder = QueryBuilder<ParseUserStudy>(this)..whereEqualTo('study_id', study.id);
    return builder.query();
  }

  Future<ParseUserStudy> getUserStudy(String objectId) async {
    final builder = QueryBuilder<ParseUserStudy>(this)..whereEqualTo('objectId', objectId);
    return builder
        .query()
        .then((response) => response.success && response.results.isNotEmpty ? response.results.first : null);
  }

  Future<String> saveUserStudy(ParseUserStudy userStudy) async {
    final response = await userStudy.save();
    if (response.success) {
      return userStudy.objectId;
    }
    print('Could not save UserStudy!');
    return null;
  }

  Future<ParseResponse> getStudyHistory() async {
    final builder = QueryBuilder<ParseUserStudy>(this)
      ..whereEqualTo(ParseUserStudy.keyUserId, await UserQueries.getOrCreateUser().then((user) => user.objectId));
    return builder.query();
  }
}
