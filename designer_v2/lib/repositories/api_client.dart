import 'package:studyu_designer_v2/utils/json_file_loader.dart';
import 'package:studyu_designer_v2/utils/typings.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:studyu_core/core.dart';

abstract class StudyUApi {
  Future<List<Study>> getUserStudies();
}

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
    print("foobar");
    return studies;
  }

}

final apiClientProvider = Provider<StudyUApi>(
        (ref) => MockApiClient()
);