import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:studyu_app/l10n/app_localizations.dart';
import 'package:studyu_app/widgets/photo_recall_section.dart';

const _photoManagerChannel = MethodChannel('com.fluttercandies/photo_manager');

Widget _testApp(Locale locale) => MaterialApp(
  supportedLocales: AppLocalizations.supportedLocales,
  localizationsDelegates: AppLocalizations.localizationsDelegates,
  locale: locale,
  home: Scaffold(body: PhotoRecallSection(mealTime: DateTime(2026, 7, 15, 12))),
);

void main() {
  setUp(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(_photoManagerChannel, (call) async {
          switch (call.method) {
            case 'getPermissionState':
              return PermissionState.authorized.index;
            case 'getAssetPathList':
              return <dynamic>[];
          }
          return null;
        });
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(_photoManagerChannel, null);
  });

  testWidgets(
    'uses direct copy and keeps photo surfaces interactive or passive',
    (tester) async {
      await tester.pumpWidget(_testApp(const Locale('en')));
      await tester.pumpAndSettle();

      expect(
        find.text('Use photos from around this time to remember what you ate.'),
        findsOneWidget,
      );
      final collapsedAction = find.ancestor(
        of: find.text('Photo Recall'),
        matching: find.byType(InkWell),
      );
      expect(collapsedAction, findsOneWidget);
      expect(tester.widget<InkWell>(collapsedAction).onTap, isNotNull);
      expect(
        tester
            .widget<Card>(
              find
                  .ancestor(
                    of: find.text('Photo Recall'),
                    matching: find.byType(Card),
                  )
                  .first,
            )
            .color,
        isNull,
      );

      await tester.tap(find.text('Photo Recall'));
      await tester.pumpAndSettle();

      final emptyLabel = find.text('No photos found');
      expect(emptyLabel, findsOneWidget);
      expect(
        find.ancestor(of: emptyLabel, matching: find.byType(Card)),
        findsWidgets,
      );
      expect(
        find.ancestor(of: emptyLabel, matching: find.byType(InkWell)),
        findsNothing,
      );
    },
  );

  testWidgets('uses natural German photo recall copy', (tester) async {
    await tester.pumpWidget(_testApp(const Locale('de')));
    await tester.pumpAndSettle();

    expect(
      find.text(
        'Nutzen Sie Fotos aus dieser Zeit, um sich daran zu erinnern, was Sie gegessen haben.',
      ),
      findsOneWidget,
    );
  });
}
