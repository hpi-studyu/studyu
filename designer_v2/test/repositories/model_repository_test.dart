import 'package:flutter_test/flutter_test.dart';
import 'package:studyu_designer_v2/repositories/model_repository.dart';

class _Model {
  const _Model(this.id);

  final String id;
}

class _Delegate implements IModelRepositoryDelegate<_Model> {
  @override
  _Model createDuplicate(_Model model) => _Model('${model.id}-copy');

  @override
  _Model createNewInstance() => const _Model('new');

  @override
  Future<void> delete(_Model model) async => throw StateError('delete failed');

  @override
  Future<_Model> fetch(ModelID modelId) async => _Model(modelId);

  @override
  Future<List<_Model>> fetchAll() async => const [];

  @override
  void onError(Object error, StackTrace? stackTrace) {}

  @override
  Future<_Model> save(_Model model) async => model;
}

class _Repository extends ModelRepository<_Model> {
  _Repository() : super(_Delegate());

  @override
  ModelID getKey(_Model model) => model.id;
}

void main() {
  test('non-optimistic delete propagates persistence errors', () async {
    final repository = _Repository();
    repository.upsertLocally(const _Model('study')).markAsFetched();

    await expectLater(
      repository.delete('study', runOptimistically: false),
      throwsA(isA<StateError>()),
    );
    expect(repository.get('study'), isNotNull);
  });
}
