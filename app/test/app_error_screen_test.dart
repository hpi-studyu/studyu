import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/test/test_flutter_secure_storage_platform.dart';
import 'package:flutter_secure_storage_platform_interface/flutter_secure_storage_platform_interface.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:studyu_app/app_router.dart';
import 'package:studyu_app/l10n/app_localizations.dart';
import 'package:studyu_app/models/app_state.dart';
import 'package:studyu_app/screens/app_onboarding/app_error_screen.dart';
import 'package:studyu_app/screens/app_onboarding/loading_screen.dart';
import 'package:studyu_app/util/cache.dart';
import 'package:studyu_core/core.dart';
import 'package:studyu_flutter_common/studyu_flutter_common.dart';

Widget buildTestApp(Widget child) {
  return MaterialApp(
    supportedLocales: AppLocalizations.supportedLocales,
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    locale: const Locale('en'),
    home: child,
  );
}

void main() {
  testWidgets('reset retains pending study data when final sync fails', (
    tester,
  ) async {
    final originalStoragePlatform = FlutterSecureStoragePlatform.instance;
    final storageData = <String, String>{};
    FlutterSecureStoragePlatform.instance = TestFlutterSecureStoragePlatform(
      storageData,
    );
    Cache.debugResetSubjectWrites();
    final study = Study('study-id', 'owner-id')
      ..title = 'Pending study'
      ..schedule.includeBaseline = false
      ..schedule.numberOfCycles = 1
      ..schedule.phaseDuration = 1
      ..interventions = [Intervention('intervention-id', 'Intervention')];
    final subject =
        StudySubject.fromStudy(study, 'user-id', ['intervention-id'], null)
          ..id = 'subject-id'
          ..startedAt = DateTime.now().subtract(const Duration(days: 1))
          ..progress = [
            SubjectProgress(
              subjectId: 'subject-id',
              interventionId: 'intervention-id',
              taskId: 'task-id',
              resultType: 'bool',
              result: Result<bool>.app(
                type: 'bool',
                periodId: 'period-id',
                result: true,
              ),
            )..completedAt = DateTime.now().toUtc(),
          ];
    final remoteSubject = StudySubject.fromJson(subject.toFullJson())
      ..progress = [];
    final appState = AppState();
    appState.debugHasParticipantSessionForSync = () => true;
    appState.debugRestoreParticipantSessionForSync = () async => false;
    appState.debugFetchRemoteSubjectForSync = (_) async => remoteSubject;
    appState.updateActiveSubject(subject);
    await Cache.storeSubject(subject);
    Cache.debugUploadBlobFilesOverride = (_, _) =>
        Future<void>.error(Exception('upload failed'));

    final router = GoRouter(
      routes: [GoRoute(path: '/', builder: (_, _) => const AppErrorScreen())],
    );

    try {
      await tester.pumpWidget(
        ChangeNotifierProvider.value(
          value: appState,
          child: MaterialApp.router(
            supportedLocales: AppLocalizations.supportedLocales,
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            locale: const Locale('en'),
            routerConfig: router,
          ),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));
      await tester.ensureVisible(find.text('Leave study and delete all data'));
      await tester.tap(find.text('Leave study and delete all data'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Reset App'));
      for (
        var attempt = 0;
        attempt < 100 && find.text('Could not save results').evaluate().isEmpty;
        attempt++
      ) {
        await tester.pump(const Duration(milliseconds: 20));
      }

      expect(find.text('Could not save results'), findsOneWidget);
      expect(appState.activeSubject, same(subject));
      expect(await SecureStorage.containsKey(cacheSubjectKey), isTrue);
    } finally {
      router.dispose();
      appState.dispose();
      Cache.debugUploadBlobFilesOverride = null;
      FlutterSecureStoragePlatform.instance = originalStoragePlatform;
      appConnectionStatusController.reset();
    }
  });

  testWidgets(
    'deleted-subject recovery preserves data before reset confirmation',
    (tester) async {
      final originalStoragePlatform = FlutterSecureStoragePlatform.instance;
      FlutterSecureStoragePlatform.instance = TestFlutterSecureStoragePlatform(
        <String, String>{},
      );
      Cache.debugResetSubjectWrites();
      final study = Study('study-id', 'owner-id')
        ..schedule.includeBaseline = false
        ..schedule.numberOfCycles = 1
        ..schedule.phaseDuration = 1
        ..interventions = [Intervention('intervention-id', 'Intervention')];
      final subject =
          StudySubject.fromStudy(study, 'user-id', ['intervention-id'], null)
            ..id = 'subject-id'
            ..startedAt = DateTime.now().subtract(const Duration(days: 1))
            ..progress = [
              SubjectProgress(
                subjectId: 'subject-id',
                interventionId: 'intervention-id',
                taskId: 'task-id',
                resultType: 'bool',
                result: Result<bool>.app(
                  type: 'bool',
                  periodId: 'period-id',
                  result: true,
                ),
              )..completedAt = DateTime.now().toUtc(),
            ];
      final appState = AppState()..updateActiveSubject(subject);
      await SecureStorage.write(selectedSubjectIdKey, subject.id);
      await SecureStorage.write('has_processed_deferred_link', 'true');
      await Cache.storeSubject(subject);
      appConnectionStatusController.setStatus(
        AppConnectionStatus.backendUnavailable,
      );
      LoadingScreen.debugRetrieveSubjectOverride = (_) =>
          Future<StudySubject?>.error(const SubjectDeletedException());
      final router = GoRouter(
        routes: [
          GoRoute(path: '/', builder: (_, _) => const LoadingScreen()),
          GoRoute(
            path: '/${RouteNames.appErrorScreen}',
            builder: (_, state) {
              final arguments = state.extra! as AppErrorScreenArguments;
              return AppErrorScreen(
                selectedSubjectId: arguments.selectedSubjectId,
                reason: arguments.reason,
              );
            },
          ),
        ],
      );

      try {
        await tester.pumpWidget(
          ChangeNotifierProvider.value(
            value: appState,
            child: MaterialApp.router(
              supportedLocales: AppLocalizations.supportedLocales,
              localizationsDelegates: AppLocalizations.localizationsDelegates,
              locale: const Locale('en'),
              routerConfig: router,
            ),
          ),
        );
        for (
          var attempt = 0;
          attempt < 100 && find.text('Study unavailable').evaluate().isEmpty;
          attempt++
        ) {
          await tester.pump(const Duration(milliseconds: 20));
        }

        expect(find.text('Study unavailable'), findsOneWidget);
        expect(appState.activeSubject, same(subject));
        expect(await SecureStorage.read(selectedSubjectIdKey), subject.id);
        expect((await Cache.loadSubject()).progress, hasLength(1));
        expect(
          find.widgetWithText(TextButton, 'Leave study and delete all data'),
          findsOneWidget,
        );
      } finally {
        router.dispose();
        appState.dispose();
        LoadingScreen.debugRetrieveSubjectOverride = null;
        Cache.debugResetSubjectWrites();
        FlutterSecureStoragePlatform.instance = originalStoragePlatform;
        appConnectionStatusController.reset();
      }
    },
  );

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
