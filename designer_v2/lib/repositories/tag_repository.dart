import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:studyu_core/core.dart';
import 'package:studyu_designer_v2/repositories/api_client.dart';

// todo implements ModelRepository<Tag>
abstract class ITagRepository {
  Future<List<Tag>> getAllTags();
  void dispose();
}

class TagRepository implements ITagRepository {
  TagRepository(this.apiClient);

  final StudyUApi apiClient;

  @override
  Future<List<Tag>> getAllTags() async {
    return await apiClient.fetchAllTags();
  }

  @override
  void dispose() {}
}

final tagRepositoryProvider = Provider<TagRepository>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return TagRepository(apiClient);
});
