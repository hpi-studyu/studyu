import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:studyu_designer_v2/features/advanced_filters/advanced_filters_controller.dart';
import '../../domain/advanced_filters_model.dart';

final currentDraftCompilerProvider = Provider<GroupNode Function()>((ref) {
  return () {
    final draft = ref.read(filterBuilderProvider);
    return draft.root; // if your draft already IS a GroupNode, you’re done.
  };
});
