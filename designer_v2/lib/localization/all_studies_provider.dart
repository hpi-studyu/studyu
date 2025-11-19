import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:studyu_core/core.dart';
import 'package:studyu_designer_v2/repositories/study_repository.dart';

/// Raw list of studies as shown on the dashboard (no filters applied).
final allStudiesProvider =
    FutureProvider.autoDispose<List<Study>>((ref) async {
  final repo = ref.watch(studyRepositoryProvider);

  // fetchAll() -> Future<List<WrappedModel<Study>>>
  final wrappedList = await repo.fetchAll();

  // 🔑 unwrap to pure Study models
  return wrappedList.map((w) => w.model).toList();
  // If this doesn't compile, check WrappedModel<T> in core:
  // it might be `.model`, `.data`, or `.value` – adjust accordingly.
});
