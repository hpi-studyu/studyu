import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:studyu_core/core.dart';
import 'package:studyu_designer_v2/domain/study.dart';
import 'package:studyu_designer_v2/repositories/api_client.dart';
import 'package:studyu_designer_v2/utils/json_file_loader.dart';
import 'package:studyu_designer_v2/utils/typings.dart';


/// A mocked API client that loads data from JSON fixtures
class MockApiClient extends JsonFileLoader implements StudyUApi {
  final int responseDelaySeconds;

  MockApiClient({
    jsonAssetsPath = 'assets/data/',
    this.responseDelaySeconds = 3
  }) : super(jsonAssetsPath);

  Future<void> _wait({int? numSeconds}) async {
    await Future.delayed(Duration(seconds: numSeconds ?? responseDelaySeconds));
  }

  // - StudyUApi

  @override
  Future<List<Study>> getUserStudies() async {
    await _wait();
    final JsonList jsonList = await parseJsonListFromAssets('user_studies.json');
    final studies = jsonList.map((jsonMap) => Study.fromJson(jsonMap)).toList();
    return studies;
  }

  @override
  Future<void> deleteStudy(Study study) {
    // TODO: implement deleteStudy
    throw UnimplementedError();
  }

  @override
  Future<Study> fetchStudy(StudyID studyId) {
    // TODO: implement fetchStudy
    throw UnimplementedError();
  }

  @override
  Future<Study> publishStudy(Study study) {
    // TODO: implement publishStudy
    throw UnimplementedError();
  }

  @override
  Future<Study> saveStudy(Study study) {
    // TODO: implement saveStudy
    throw UnimplementedError();
  }
}

final apiClientProvider = Provider<StudyUApi>((ref) => MockApiClient());