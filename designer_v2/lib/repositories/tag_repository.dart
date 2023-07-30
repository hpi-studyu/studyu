import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:studyu_core/core.dart';
import 'package:studyu_designer_v2/repositories/api_client.dart';
import 'package:studyu_designer_v2/utils/extensions.dart';
import 'package:uuid/uuid.dart';

abstract class ITagRepository {
  Future<List<Tag>> fetchAll();
  Future<Tag> createTagIfNotExists(String tagName);
  Future<Tag> save(Tag tag);
  Future<void> delete(Tag tag);
}

class TagRepository implements ITagRepository {
  TagRepository(this.apiClient);

  final StudyUApi apiClient;

  @override
  Future<List<Tag>> fetchAll() {
    return apiClient.fetchAllTags();
  }

  @override
  Future<Tag> createTagIfNotExists(String tagName) async {
    final maybeTag = (await fetchAll()).firstWhereOrNull((element) => element.name == tagName);
    if (maybeTag == null) {
      return await save(Tag(name: tagName, id: const Uuid().v4()));
    }
    return Future.value(maybeTag);
  }

  @override
  Future<Tag> save(Tag tag) {
    print("try to save tag ${tag.name}");
    return apiClient.saveTag(tag);
  }

  @override
  Future<void> delete(Tag tag) {
    return apiClient.deleteTag(tag);
  }
}

final tagRepositoryProvider = Provider<TagRepository>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return TagRepository(apiClient);
});
