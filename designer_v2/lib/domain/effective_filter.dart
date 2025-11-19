import 'package:studyu_designer_v2/domain/advanced_filters_model.dart';
import 'package:studyu_designer_v2/domain/saved_filters.dart';

class EffectiveFilter {
  final GroupNode logicTree;
  final SortPreset? sortPreset;

  const EffectiveFilter({
    required this.logicTree,
    this.sortPreset,
  });
}
