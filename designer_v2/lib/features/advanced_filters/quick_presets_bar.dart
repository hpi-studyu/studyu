import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:studyu_designer_v2/domain/saved_filters.dart';
import 'package:studyu_designer_v2/localization/saved_filters_controller.dart';

import 'quick_presets.dart';

class QuickPresetsBar extends ConsumerWidget {
  const QuickPresetsBar({super.key, this.scope = FilterScope.myStudies});
  final FilterScope scope;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final thresholds = const GlobalThresholds();

    final presets = <SavedFilter>[
      QuickPresets.myActiveStudies(scope),
      QuickPresets.studiesNeedingAttention(scope, thresholds),
      QuickPresets.recentlyCreated(scope),
      QuickPresets.publicStudies(scope),
      QuickPresets.draftStudies(scope),
    ];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: presets.map((p) {
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: GestureDetector(
              onLongPress: () async {
                // Save as custom from preset definition
                await ref.read(savedFiltersProvider.notifier).saveAs(
                      name: p.name,
                      scope: p.scope,
                      sortPreset: p.sortPreset,
                      makeDefault: false,
                    );
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Saved “${p.name}”')),
                  );
                }
              },
              child: ActionChip(
                label: Text(p.name),
                onPressed: () {
                  // 1) apply preset
                  ref.read(activeFilterFromSavedProvider.notifier).state = p;

                  // 2) optionally mark last-used for analytics
                  // (only if you want; this is not required)
                  // ref.read(savedFiltersProvider.notifier).touchLastUsed(p.id);

                  // 3) close Advanced Filters so dashboard becomes visible again
                  if (context.mounted) {
                    Navigator.of(context).maybePop();
                  }
                },
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
