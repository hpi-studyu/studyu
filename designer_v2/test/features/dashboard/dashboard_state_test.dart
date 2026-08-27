import 'package:flutter_test/flutter_test.dart';
import 'package:studyu_designer_v2/features/dashboard/studies_filter.dart';
import 'package:studyu_designer_v2/features/dashboard/studies_filter/filter_types.dart';

void main() {
  group('mergeStudiesFilters', () {
    test('combines base and active filters when both are present', () {
      final baseFilter = FilterGroup(
        id: 'base-group',
        children: [
          FilterCondition(
            id: 'base-condition',
            property: StudyProperty.owner,
            operator: FilterOperator.equals,
            value: true,
          ),
        ],
      );
      final activeFilter = FilterGroup(id: 'active-group');

      final merged = mergeStudiesFilters(
        baseFilter: baseFilter,
        activeFilter: activeFilter,
      );

      expect(merged.children, hasLength(2));
      expect(merged.children[0], same(baseFilter));
      expect(merged.children[1], same(activeFilter));
    });

    test('falls back to active filter when base filter is missing', () {
      final activeFilter = FilterGroup(id: 'active-group');

      final merged = mergeStudiesFilters(
        baseFilter: null,
        activeFilter: activeFilter,
      );

      expect(merged, same(activeFilter));
    });

    test('falls back to base filter when active filter is missing', () {
      final baseFilter = FilterGroup(id: 'base-group');

      final merged = mergeStudiesFilters(
        baseFilter: baseFilter,
        activeFilter: null,
      );

      expect(merged, same(baseFilter));
    });

    test('returns empty filter when both filters are missing', () {
      final merged = mergeStudiesFilters(baseFilter: null, activeFilter: null);

      expect(merged.children, isEmpty);
    });
  });
}
