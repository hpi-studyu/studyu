import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:studyu_app/l10n/app_localizations.dart';
import 'package:studyu_app/screens/app_onboarding/app_error_screen.dart';

Widget buildTestApp(Widget child) {
  return MaterialApp(
    supportedLocales: AppLocalizations.supportedLocales,
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    locale: const Locale('en'),
    home: child,
  );
}

void main() {
  testWidgets('cache missing error screen renders recoverable copy', (
    tester,
  ) async {
    await tester.pumpWidget(
      buildTestApp(
        const AppErrorScreen(reason: AppErrorReason.cacheUnavailableMissing),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.text('Cached study data not found'), findsOneWidget);
    expect(
      find.textContaining('could not find cached study data'),
      findsOneWidget,
    );
    expect(find.text('Contact Support'), findsOneWidget);
    expect(find.text('Leave study and delete all data'), findsOneWidget);
  });

  testWidgets('cache corrupt error screen renders recoverable copy', (
    tester,
  ) async {
    await tester.pumpWidget(
      buildTestApp(
        const AppErrorScreen(reason: AppErrorReason.cacheUnavailableCorrupt),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.text('Cached study data could not be read'), findsOneWidget);
    expect(find.textContaining('could not be restored safely'), findsOneWidget);
    expect(find.text('Contact Support'), findsOneWidget);
    expect(find.text('Leave study and delete all data'), findsOneWidget);
  });
}
