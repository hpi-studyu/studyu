import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:provider/provider.dart';
import 'package:studyu_app/l10n/app_localizations.dart';
import 'package:studyu_app/models/app_state.dart';
import 'package:studyu_app/screens/study/dashboard/settings.dart';
import 'package:studyu_app/screens/study/dashboard/study_information.dart';
import 'package:studyu_core/core.dart';
import 'package:studyu_flutter_common/studyu_flutter_common.dart';

void main() {
  testWidgets('shows study and participant details', (tester) async {
    String? clipboardText;
    tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
      SystemChannels.platform,
      (call) async {
        if (call.method == 'Clipboard.setData') {
          clipboardText =
              (call.arguments as Map<Object?, Object?>)['text']! as String;
        }
        return null;
      },
    );
    addTearDown(
      () => tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
        SystemChannels.platform,
        null,
      ),
    );

    PackageInfo.setMockInitialValues(
      appName: 'StudyU',
      packageName: 'health.studyu.app',
      version: '2.14.0',
      buildNumber: '42',
      buildSignature: '',
    );
    final study = Study('study-1', 'researcher-1')
      ..title = 'Sleep study'
      ..contact.email = 'researcher@example.org';
    final subject = StudySubject('subject-1', study.id, 'user-1', const [])
      ..study = study
      ..startedAt = DateTime(2026, 7, 10);
    final appState = AppState()..activeSubject = subject;

    await tester.pumpWidget(
      ChangeNotifierProvider.value(
        value: appState,
        child: const MaterialApp(
          supportedLocales: AppLocalizations.supportedLocales,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          locale: Locale('en'),
          home: StudyInformationScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Study information'), findsOneWidget);
    expect(find.text('Sleep study'), findsOneWidget);
    expect(find.text('study-1'), findsOneWidget);
    expect(find.text('subject-1'), findsOneWidget);
    expect(find.text('2.14.0 (42)'), findsOneWidget);
    expect(find.byTooltip('Copy to clipboard'), findsNWidgets(7));

    await tester.scrollUntilVisible(
      find.text('Copy all information'),
      200,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.tap(find.text('Copy all information'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));
    expect(clipboardText, contains('Study ID: study-1\nSubject ID: subject-1'));
    expect(find.text('All information copied to clipboard.'), findsOneWidget);

    expect(
      tester
          .widget<FilledButton>(
            find.widgetWithText(FilledButton, 'Email study team'),
          )
          .onPressed,
      isNotNull,
    );
  });

  testWidgets('opens study information from settings', (tester) async {
    PackageInfo.setMockInitialValues(
      appName: 'StudyU',
      packageName: 'health.studyu.app',
      version: '2.14.0',
      buildNumber: '42',
      buildSignature: '',
    );
    final study = Study('study-1', 'researcher-1')..title = 'Sleep study';
    final subject = StudySubject('subject-1', study.id, 'user-1', const [])
      ..study = study
      ..startedAt = DateTime(2026, 7, 10);
    final appState = AppState()..activeSubject = subject;
    final appLanguage = _TestAppLanguage();
    addTearDown(appLanguage.dispose);
    final router = GoRouter(
      initialLocation: '/settings',
      routes: [
        GoRoute(path: '/settings', builder: (_, _) => const Settings()),
        GoRoute(
          path: '/studyInformation',
          builder: (_, _) => const StudyInformationScreen(),
        ),
      ],
    );
    addTearDown(router.dispose);

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider.value(value: appState),
          ChangeNotifierProvider<AppLanguage>.value(value: appLanguage),
        ],
        child: MaterialApp.router(
          supportedLocales: AppLocalizations.supportedLocales,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          locale: const Locale('en'),
          routerConfig: router,
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Use device language'), findsOneWidget);
    expect(find.text('Study settings'), findsOneWidget);
    expect(find.text('Dashboard walkthrough'), findsOneWidget);
    expect(find.text('Replay tour'), findsOneWidget);
    expect(find.text('Show dashboard tour again'), findsNothing);
    expect(find.byIcon(Icons.language), findsOneWidget);
    expect(find.byIcon(Icons.help_outline), findsOneWidget);
    expect(find.byIcon(Icons.lock_outline), findsOneWidget);
    expect(
      find.descendant(
        of: find.byKey(
          const ValueKey('settings_show_dashboard_showcase_again'),
        ),
        matching: find.byType(Icon),
      ),
      findsNothing,
    );
    expect(
      tester.widget<Text>(find.text('View recovery phrase')).style?.fontWeight,
      isNot(FontWeight.w500),
    );
    expect(
      tester.widget<Text>(find.text('General')).style?.color,
      tester.widget<Text>(find.text('Study settings')).style?.color,
    );
    final studyCards = tester
        .widgetList<Card>(find.byType(Card))
        .skip(1)
        .take(3)
        .toList();
    expect(studyCards[0].margin, studyCards[1].margin);
    expect(studyCards[1].margin, studyCards[2].margin);
    expect(find.text('Sleep study'), findsNothing);
    expect(find.text('Study information'), findsOneWidget);
    expect(find.text('View details'), findsOneWidget);

    await tester.scrollUntilVisible(
      find.byKey(const ValueKey('settings_study_information')),
      200,
      scrollable: find.byType(Scrollable).first,
    );
    expect(find.byIcon(Icons.science_outlined), findsOneWidget);
    expect(
      find.descendant(
        of: find.byKey(const ValueKey('settings_study_information')),
        matching: find.byType(Icon),
      ),
      findsNothing,
    );
    await tester.scrollUntilVisible(
      find.text('Manage participation'),
      200,
      scrollable: find.byType(Scrollable).first,
    );
    expect(find.text('Manage participation'), findsOneWidget);
    expect(find.text('Leave study and delete my data'), findsOneWidget);
    expect(
      find.text(
        'Stop participating. Your existing study data will be retained.',
      ),
      findsOneWidget,
    );
    expect(
      find.text('Permanently delete your study data. This cannot be undone.'),
      findsOneWidget,
    );

    await tester.scrollUntilVisible(
      find.byKey(const ValueKey('settings_study_information')),
      -200,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.tap(find.byKey(const ValueKey('settings_study_information')));
    await tester.pumpAndSettle();

    expect(find.byType(StudyInformationScreen), findsOneWidget);
  });

  testWidgets('shows destructive study dialogs consistently', (tester) async {
    final study = Study('study-1', 'researcher-1')..title = 'Sleep study';
    final subject = StudySubject('subject-1', study.id, 'user-1', const [])
      ..study = study;

    await tester.pumpWidget(
      MaterialApp(
        supportedLocales: AppLocalizations.supportedLocales,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        locale: const Locale('en'),
        home: OptOutAlertDialog(subject: subject),
      ),
    );

    expect(find.text('Leave study and keep your data?'), findsOneWidget);
    expect(
      find.text(
        'You will stop participating in the study “Sleep study”. We will keep the progress and responses you have already submitted, and researchers may continue to use your anonymized data.\n\nYou cannot rejoin this participation after leaving. Your previous studies will not be affected.',
      ),
      findsOneWidget,
    );
    expect(
      find.widgetWithText(OutlinedButton, 'Stay in study'),
      findsOneWidget,
    );
    final acknowledgement = find.text(
      'I have read this information and understand the consequences.',
    );
    expect(acknowledgement, findsOneWidget);
    expect(
      tester.widget<Text>(acknowledgement).style,
      Theme.of(tester.element(acknowledgement)).textTheme.bodyMedium,
    );
    var leaveButton = tester.widget<ElevatedButton>(
      find.widgetWithText(ElevatedButton, 'Leave and keep my data'),
    );
    expect(leaveButton.onPressed, isNull);
    await tester.tap(find.byType(Checkbox));
    await tester.pump();
    leaveButton = tester.widget<ElevatedButton>(
      find.widgetWithText(ElevatedButton, 'Leave and keep my data'),
    );
    expect(leaveButton.onPressed, isNotNull);
    expect(
      leaveButton.style?.backgroundColor?.resolve(const {}),
      Colors.red[700],
    );

    await tester.pumpWidget(
      MaterialApp(
        supportedLocales: AppLocalizations.supportedLocales,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        locale: const Locale('en'),
        home: DeleteAlertDialog(subject: subject),
      ),
    );

    expect(find.text('Leave study and delete my data?'), findsOneWidget);
    expect(
      find.text(
        'You will stop participating in the study “Sleep study”. We will permanently delete your progress and responses for this study from our servers and remove its saved data from this device.\n\nThis cannot be undone. Neither you nor anyone from the study team will be able to recover this data.',
      ),
      findsOneWidget,
    );
    expect(
      find.widgetWithText(OutlinedButton, 'Stay in study'),
      findsOneWidget,
    );
    var deleteButton = tester.widget<ElevatedButton>(
      find.widgetWithText(ElevatedButton, 'Leave and delete my data'),
    );
    expect(deleteButton.onPressed, isNull);
    await tester.tap(find.byType(Checkbox));
    await tester.pump();
    deleteButton = tester.widget<ElevatedButton>(
      find.widgetWithText(ElevatedButton, 'Leave and delete my data'),
    );
    expect(deleteButton.onPressed, isNotNull);
  });
}

class _TestAppLanguage extends ChangeNotifier implements AppLanguage {
  @override
  Locale? get appLocal => null;

  @override
  List<Locale> get supportedLocales => AppLocalizations.supportedLocales;

  @override
  Future<void> changeLanguage(Locale? locale) async {}

  @override
  Future<void> fetchLocale() async {}
}
