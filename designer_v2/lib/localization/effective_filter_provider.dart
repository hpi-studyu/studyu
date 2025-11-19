import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:studyu_designer_v2/features/advanced_filters/advanced_filters_controller.dart';

import 'saved_filters_controller.dart';      // filterBuilderProvider
import '../domain/effective_filter.dart';

final effectiveFilterProvider = Provider<EffectiveFilter?>((ref) {
  // 1) Saved filter / quick preset wins
  final saved = ref.watch(activeFilterFromSavedProvider);
  if (saved != null) {
    return EffectiveFilter(
      logicTree: saved.logicTree,
      sortPreset: saved.sortPreset,
    );
  }

  // 2) Otherwise: live builder draft
  final draft = ref.watch(filterBuilderProvider);
  if (draft != null) {
    return EffectiveFilter(
      logicTree: draft.root,
      sortPreset: null,
    );
  }

  // 3) No filter → show all
  return null;
});
