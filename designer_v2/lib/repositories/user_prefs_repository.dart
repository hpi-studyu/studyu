import 'package:studyu_designer_v2/domain/saved_filters.dart';
import 'package:uuid/uuid.dart';

import 'user_prefs_api.dart';

class UserPrefsRepository {
  final UserPrefsApi api;
  UserPrefsRepository(this.api);

  Future<Map<String, dynamic>> _load() => api.fetch();
  Future<void> _save(Map<String, dynamic> prefs) => api.save(prefs);

  Future<List<SavedFilter>> list() async {
    final prefs = await _load();
    final raw = (prefs['savedFilters'] as List?) ?? const [];
    return raw
        .map((e) => SavedFilter.fromJson(Map<String, dynamic>.from(e as Map)))
        .toList(growable: false);
  }

  Future<SavedFilter> rename(String id, String newName) async {
    final prefs = await _load();
    final List<Map<String, dynamic>> arr =
        ((prefs['savedFilters'] as List?) ?? const [])
            .map((e) => Map<String, dynamic>.from(e as Map))
            .toList();

    final idx = arr.indexWhere((x) => x['id'] == id);
    if (idx < 0) {
      throw StateError('Filter not found');
    }
    arr[idx]['name'] = newName.trim();
    arr[idx]['updatedAt'] = DateTime.now().toUtc().toIso8601String();

    prefs['savedFilters'] = arr;
    await _save(prefs);
    return SavedFilter.fromJson(arr[idx]);
  }


  Future<SavedFilter> saveNew({
    required String name,
    required SavedFilter seed, // contains scope, logicTree, sortPreset
    bool makeDefault = false,
  }) async {
    final now = DateTime.now().toUtc();
    final prefs = await _load();
    final List<Map<String, dynamic>> arr =
        ((prefs['savedFilters'] as List?) ?? const [])
            .map((e) => Map<String, dynamic>.from(e as Map))
            .toList();

    if (makeDefault) {
      for (final f in arr) { f['isDefault'] = false; }
    }

    final f = SavedFilter(
      id: const Uuid().v4(),
      name: name.trim(),
      isDefault: makeDefault,
      createdAt: now,
      updatedAt: now,
      lastUsedAt: now,
      scope: seed.scope,
      logicTree: seed.logicTree,
      sortPreset: seed.sortPreset,
    );

    arr.add(f.toJson());
    prefs['savedFilters'] = arr;
    await _save(prefs);
    return f;
  }

  Future<SavedFilter> update(SavedFilter f) async {
    final prefs = await _load();
    final List<Map<String, dynamic>> arr =
        ((prefs['savedFilters'] as List?) ?? const [])
            .map((e) => Map<String, dynamic>.from(e as Map))
            .toList();

    if (f.isDefault) {
      for (final x in arr) { x['isDefault'] = false; }
    }
    final idx = arr.indexWhere((x) => x['id'] == f.id);
    final patch = f.copyWith(updatedAt: DateTime.now().toUtc()).toJson();
    if (idx >= 0) arr[idx] = patch; else arr.add(patch);

    prefs['savedFilters'] = arr;
    await _save(prefs);
    return SavedFilter.fromJson(patch);
  }

  Future<void> delete(String id) async {
    final prefs = await _load();
    final List<Map<String, dynamic>> arr =
        ((prefs['savedFilters'] as List?) ?? const [])
            .map((e) => Map<String, dynamic>.from(e as Map))
            .toList();
    prefs['savedFilters'] = arr.where((x) => x['id'] != id).toList();
    await _save(prefs);
  }

  Future<SavedFilter?> setDefault(String id) async {
    final prefs = await _load();
    final List<Map<String, dynamic>> arr =
        ((prefs['savedFilters'] as List?) ?? const [])
            .map((e) => Map<String, dynamic>.from(e as Map))
            .toList();

    Map<String, dynamic>? found;
    for (final x in arr) {
      x['isDefault'] = (x['id'] == id);
      if (x['isDefault'] == true) {
        x['updatedAt'] = DateTime.now().toUtc().toIso8601String();
        found = x;
      }
    }
    prefs['savedFilters'] = arr;
    await _save(prefs);
    return found == null ? null : SavedFilter.fromJson(found);
  }

  Future<void> touchLastUsed(String id) async {
    final prefs = await _load();
    final List<Map<String, dynamic>> arr =
        ((prefs['savedFilters'] as List?) ?? const [])
            .map((e) => Map<String, dynamic>.from(e as Map))
            .toList();
    for (final x in arr) {
      if (x['id'] == id) x['lastUsedAt'] = DateTime.now().toUtc().toIso8601String();
    }
    prefs['savedFilters'] = arr;
    await _save(prefs);
  }
}
