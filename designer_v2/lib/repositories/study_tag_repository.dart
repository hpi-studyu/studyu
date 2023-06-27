import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:studyu_core/core.dart';
import 'package:studyu_designer_v2/repositories/api_client.dart';

// todo implements ModelRepository<StudyTag>?
abstract class IStudyTagRepository {
  Future<List<StudyTag>> getStudyTags();
  void dispose();
}

class StudyTagRepository implements IStudyTagRepository {
  StudyTagRepository(this.apiClient);

  final StudyUApi apiClient;

  @override
  Future<List<StudyTag>> getStudyTags() async {
    return await apiClient.getStudyTags();
  }

  @override
  void dispose() {}
}

final studyTagRepositoryProvider = Provider<StudyTagRepository>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return StudyTagRepository(apiClient);
});
