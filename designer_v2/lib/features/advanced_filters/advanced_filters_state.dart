import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:studyu_designer_v2/features/advanced_filters/created_at_filter.dart';
import 'package:studyu_designer_v2/domain/advanced_filters_model.dart';

/// UI-only flag to know if the Advanced Filters panel is open.
/// (The actual filter query state will come in the next task.)
final advancedFiltersOpenProvider = StateProvider<bool>((_) => false);

final createdAtPresetProvider =
    StateProvider<CreatedAtPreset>((_) => CreatedAtPreset.any);

// If you support a custom range, keep it separately
class DateRange {
  final DateTime? start;
  final DateTime? end;
  const DateRange({this.start, this.end});
}

final customCreatedRangeProvider =
    StateProvider<DateRange>((_) => const DateRange());

/// ---------------------------------------------------------------------------
/// Type-aware metadata (so the Value control adapts to a field's type)
/// ---------------------------------------------------------------------------

enum FilterPropType {
  string,
  number,
  boolean,
  date,
  datetime,
  enumeration,
}

class FilterEnumOption {
  final String key;   // canonical key to store (e.g. "draft")
  final String label; // user label (e.g. "Draft")
  const FilterEnumOption(this.key, this.label);
}

class FilterFieldMeta {
  final String label;
  final FilterPropType type;
  final bool multi;
  final List<FilterEnumOption> options;
  final num? min;
  final num? max;

  const FilterFieldMeta({
    required this.label,
    required this.type,
    this.multi = false,
    this.options = const [],
    this.min,
    this.max,
  });

  bool get isEnum => type == FilterPropType.enumeration;
}

/// Central registry: what each StudyField is and how to edit its value.
/// (Adjust labels/options if your domain changes.)
const Map<StudyField, FilterFieldMeta> kFieldMeta = {
  StudyField.title: FilterFieldMeta(
    label: 'Title',
    type: FilterPropType.string,
  ),
  StudyField.status: FilterFieldMeta(
    label: 'Status',
    type: FilterPropType.enumeration,
    options: [
      FilterEnumOption('draft', 'Draft'),
      FilterEnumOption('published', 'Published'),
      FilterEnumOption('archived', 'Archived'),
    ],
  ),
  StudyField.owner: FilterFieldMeta(
    label: 'Owner',
    type: FilterPropType.string,
  ),
  StudyField.createdAt: FilterFieldMeta(
    label: 'Created at',
    type: FilterPropType.date,
  ),
  StudyField.resultSharing: FilterFieldMeta(
    label: 'Result sharing',
    type: FilterPropType.enumeration,
    options: [
      FilterEnumOption('none', 'None'),
      FilterEnumOption('summary', 'Summary'),
      FilterEnumOption('individual', 'Individual'),
    ],
  ),
  StudyField.registryPublished: FilterFieldMeta(
    label: 'Registry published',
    type: FilterPropType.boolean,
  ),
  StudyField.participation: FilterFieldMeta(
    label: 'Participation',
    type: FilterPropType.number,
    min: 0,
  ),
  StudyField.totalMissedDays: FilterFieldMeta(
    label: 'Total missed days',
    type: FilterPropType.number,
    min: 0,
  ),
};
