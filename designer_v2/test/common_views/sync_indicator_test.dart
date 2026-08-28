import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:studyu_designer_v2/common_views/sync_indicator.dart';
import 'package:studyu_designer_v2/localization/app_localizations_en.dart';
import 'package:studyu_designer_v2/localization/app_translation.dart';

void main() {
  setUpAll(() => AppTranslation.setForTesting(AppLocalizationsEn()));

  testWidgets('saved state uses neutral icon color and copy', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Material(
          child: SyncIndicator<void>(
            state: AsyncData<void>(null),
            isDirty: false,
          ),
        ),
      ),
    );

    final iconFinder = find.byKey(const ValueKey('sync_indicator_saved'));
    final tooltipFinder = find.ancestor(
      of: iconFinder,
      matching: find.byType(Tooltip),
    );
    final icon = tester.widget<Icon>(iconFinder);
    final tooltip = tester.widget<Tooltip>(tooltipFinder);
    final theme = Theme.of(tester.element(find.byType(SyncIndicator<void>)));

    expect(icon.color, theme.iconTheme.color!.withValues(alpha: 0.45));
    expect(tooltip.message, 'All changes saved');
    expect(tooltip.message, isNot(contains('Last saved')));
  });

  testWidgets('dirty and saving states still render dedicated icons', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Column(
          children: [
            Material(
              child: SyncIndicator<void>(
                state: AsyncData<void>(null),
                isDirty: true,
              ),
            ),
            Material(
              child: SyncIndicator<void>(
                state: AsyncLoading<void>(),
                isDirty: true,
              ),
            ),
          ],
        ),
      ),
    );

    expect(find.byKey(const ValueKey('sync_indicator_dirty')), findsOneWidget);
    expect(
      find.byKey(const ValueKey('sync_indicator_refreshing')),
      findsOneWidget,
    );
  });

  testWidgets('error state still renders problem icon', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Material(
          child: SyncIndicator<void>(
            state: AsyncError<void>('boom', StackTrace.empty),
            isDirty: true,
          ),
        ),
      ),
    );

    expect(find.byKey(const ValueKey('sync_indicator_error')), findsOneWidget);
  });
}
