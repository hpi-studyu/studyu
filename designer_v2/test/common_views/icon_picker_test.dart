import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:studyu_designer_v2/common_views/icon_picker.dart';
import 'package:studyu_designer_v2/localization/app_localizations_en.dart';
import 'package:studyu_designer_v2/localization/app_translation.dart';

void main() {
  setUpAll(() => AppTranslation.setForTesting(AppLocalizationsEn()));

  testWidgets('selected icon does not render inline clear badge', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Material(
          child: IconPickerField(
            iconOptions: <IconOption>[
              IconOption('account', Icons.account_circle_outlined),
            ],
            selectedOption: IconOption(
              'account',
              Icons.account_circle_outlined,
            ),
          ),
        ),
      ),
    );

    expect(find.byIcon(Icons.close_rounded), findsNothing);
  });

  testWidgets('modal shows cancel and remove actions when icon exists', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Material(
          child: IconPickerField(
            iconOptions: <IconOption>[
              IconOption('account', Icons.account_circle_outlined),
            ],
            selectedOption: IconOption('missingLegacyIcon'),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Change icon'));
    await tester.pumpAndSettle();

    expect(find.text('Cancel'), findsOneWidget);
    expect(find.text('Remove icon'), findsOneWidget);
  });

  testWidgets('modal omits remove action when icon is empty', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Material(
          child: IconPickerField(
            iconOptions: <IconOption>[
              IconOption('account', Icons.account_circle_outlined),
            ],
          ),
        ),
      ),
    );

    await tester.tap(find.text('Pick an icon'));
    await tester.pumpAndSettle();

    expect(find.text('Cancel'), findsOneWidget);
    expect(find.text('Remove icon'), findsNothing);
  });

  testWidgets('unknown stored icon falls back to text trigger', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Material(
          child: IconPickerField(
            iconOptions: <IconOption>[
              IconOption('account', Icons.account_circle_outlined),
            ],
            selectedOption: IconOption('missingLegacyIcon'),
          ),
        ),
      ),
    );

    expect(find.text('Change icon'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('modal filters icons by search query', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Material(
          child: IconPickerField(
            iconOptions: <IconOption>[
              IconOption('account', Icons.account_circle_outlined),
              IconOption('car', Icons.directions_car_outlined),
            ],
          ),
        ),
      ),
    );

    await tester.tap(find.text('Pick an icon'));
    await tester.pumpAndSettle();

    expect(find.byIcon(Icons.account_circle_outlined), findsOneWidget);
    expect(find.byIcon(Icons.directions_car_outlined), findsOneWidget);

    await tester.enterText(find.byType(SearchBar), 'car');
    await tester.pumpAndSettle();

    expect(find.byIcon(Icons.account_circle_outlined), findsNothing);
    expect(find.byIcon(Icons.directions_car_outlined), findsOneWidget);
  });

  testWidgets('modal shows empty state when search has no matches', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Material(
          child: IconPickerField(
            iconOptions: <IconOption>[
              IconOption('account', Icons.account_circle_outlined),
            ],
          ),
        ),
      ),
    );

    await tester.tap(find.text('Pick an icon'));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(SearchBar), 'zzz');
    await tester.pumpAndSettle();

    expect(find.text('No icons found'), findsOneWidget);
    expect(find.byIcon(Icons.account_circle_outlined), findsNothing);
  });
}
