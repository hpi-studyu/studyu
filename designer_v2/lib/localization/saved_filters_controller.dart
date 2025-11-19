import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:studyu_designer_v2/domain/saved_filters.dart';
import 'package:studyu_designer_v2/localization/compile_logic.dart';
import 'package:studyu_designer_v2/repositories/user_prefs_api.dart';
import 'package:studyu_designer_v2/repositories/user_prefs_repository.dart';


// API provider (swap with your real backend adapter later)
final userPrefsApiProvider = Provider<UserPrefsApi>((ref) => InMemoryUserPrefsApi());

// Repo
final userPrefsRepoProvider = Provider<UserPrefsRepository>(
  (ref) => UserPrefsRepository(ref.read(userPrefsApiProvider)),
);

// currently applied saved filter (dashboard listens to this)
final activeFilterFromSavedProvider = StateProvider<SavedFilter?>((_) => null);

// list & mutations
final savedFiltersProvider =
    StateNotifierProvider<SavedFiltersController, AsyncValue<List<SavedFilter>>>(
  (ref) => SavedFiltersController(ref),
);

class SavedFiltersController extends StateNotifier<AsyncValue<List<SavedFilter>>> {
  final Ref ref;
  SavedFiltersController(this.ref) : super(const AsyncLoading()) {
    refresh();
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    try {
      final list = await ref.read(userPrefsRepoProvider).list();
      state = AsyncData<List<SavedFilter>>(list);
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }

  Future<void> rename(String id, String newName) async {
    final updated = await ref.read(userPrefsRepoProvider).rename(id, newName);
    final cur = (state.value ?? const <SavedFilter>[])
        .map((f) => f.id == id ? updated : f)
        .toList();
    state = AsyncData<List<SavedFilter>>(cur);
  }



  Future<void> saveAs({
    required String name,
    required FilterScope scope,
    SortPreset? sortPreset,
    bool makeDefault = false,
  }) async {
    final logic = ref.read(currentDraftCompilerProvider)(); // GroupNode from builder
    final seed = SavedFilter(
      id: 'seed', // ignored in repo.saveNew
      name: name,
      isDefault: makeDefault,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      scope: scope,
      logicTree: logic,
      lastUsedAt: DateTime.now(),
      sortPreset: sortPreset,
    );
    final saved = await ref.read(userPrefsRepoProvider).saveNew(
      name: name,
      seed: seed,
      makeDefault: makeDefault,
    );
    final cur = <SavedFilter>[...(state.value ?? const []), saved];
    state = AsyncData<List<SavedFilter>>(cur);
  }

  Future<void> setDefault(String id) async {
    final def = await ref.read(userPrefsRepoProvider).setDefault(id);
    if (def == null) return;
    final cur = (state.value ?? const <SavedFilter>[])
        .map((f) => f.id == def.id ? def : (f.isDefault ? f.copyWith(isDefault: false) : f))
        .toList();
    state = AsyncData<List<SavedFilter>>(cur);
  }

  Future<void> delete(String id) async {
    await ref.read(userPrefsRepoProvider).delete(id);
    final cur = (state.value ?? const <SavedFilter>[])..removeWhere((f) => f.id == id);
    state = AsyncData<List<SavedFilter>>(cur);
  }

  Future<void> touchLastUsed(String id) async {
    await ref.read(userPrefsRepoProvider).touchLastUsed(id);
  }
}

// default on dashboard
final defaultFilterProvider = Provider<SavedFilter?>((ref) {
  final list = ref.watch(savedFiltersProvider).value ?? const <SavedFilter>[];
  for (final f in list) {
    if (f.isDefault) return f;
  }
  return null;
});
