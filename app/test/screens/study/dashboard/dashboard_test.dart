import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:studyu_app/l10n/app_localizations.dart';
import 'package:studyu_app/models/app_state.dart';
import 'package:studyu_app/screens/study/dashboard/dashboard.dart';
import 'package:studyu_app/screens/study/dashboard/task_overview_tab/task_overview.dart';
import 'package:studyu_app/services/restore_account_service.dart';
import 'package:studyu_app/util/dashboard_showcase.dart';
import 'package:studyu_core/core.dart';

Widget _dashboardWith(
  int interventionCount, {
  bool withTask = false,
  bool preview = true,
  DateTime? startedAt,
}) {
  final study = Study('study', 'user')
    ..status = StudyStatus.running
    ..interventions = List.generate(
      interventionCount,
      (index) => Intervention('intervention-$index', 'Intervention $index'),
    );
  if (withTask) {
    study.interventions.single.tasks = [
      CheckmarkTask.withId()..title = 'Ignored task',
    ];
  }

  final subject = StudySubject.fromStudy(
    study,
    'user',
    study.interventions.map((intervention) => intervention.id).toList(),
    null,
  )..startedAt = startedAt ?? DateTime.now().add(const Duration(days: 1));
  final appState = AppState()..activeSubject = subject;
  appState.updatePreviewMode(preview);

  return ChangeNotifierProvider.value(
    value: appState,
    child: const MaterialApp(
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      locale: Locale('en'),
      home: DashboardScreen(),
    ),
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    RestoreAccountService.debugCurrentUserIdGetterForTesting = () => 'user';
    RestoreAccountService.debugRecoveryIdGetterForTesting = () async =>
        '00000000-0000-0000-0000-000000000001';
  });

  tearDown(() {
    RecoveryPhraseStorage.debugResetForTesting();
    RestoreAccountService.debugResetCurrentUserIdGetterForTesting();
    RestoreAccountService.debugResetRecoveryIdGetterForTesting();
    RestoreAccountService.clearCache();
  });

  testWidgets('study with one intervention stays unavailable despite tasks', (
    tester,
  ) async {
    await tester.pumpWidget(_dashboardWith(1, withTask: true));

    expect(
      find.text('This study is not available for testing yet.'),
      findsOneWidget,
    );
    expect(find.byType(AppBar), findsNothing);
    expect(find.byType(TaskOverview), findsNothing);
    expect(find.text('Dashboard'), findsNothing);
  });

  testWidgets('study with two interventions shows dashboard', (tester) async {
    await tester.pumpWidget(_dashboardWith(2));

    expect(
      find.text('This study is not available for testing yet.'),
      findsNothing,
    );
    expect(find.byType(AppBar), findsOneWidget);
    expect(find.text('Dashboard'), findsOneWidget);
  });

  testWidgets(
    'pending recovery phrase requires confirmation before its prompt dismisses',
    (tester) async {
      var isPending = true;
      RecoveryPhraseStorage.debugConfigureForTesting(
        readPending: (_) async => isPending,
        clearPending: (_) async => isPending = false,
      );

      await tester.pumpWidget(
        _dashboardWith(2, preview: false, startedAt: DateTime.now()),
      );
      await tester.pumpAndSettle();

      expect(find.text('View recovery phrase'), findsOneWidget);
      final continueButton = tester.widget<FilledButton>(
        find.widgetWithText(FilledButton, 'Continue to study'),
      );
      expect(continueButton.onPressed, isNull);

      final confirmation = find.byType(CheckboxListTile);
      await tester.ensureVisible(confirmation);
      await tester.tap(confirmation);
      await tester.pumpAndSettle();
      expect(
        tester.widget<FilledButton>(
          find.widgetWithText(FilledButton, 'Continue to study'),
        ).onPressed,
        isNotNull,
      );

      await tester.tap(find.widgetWithText(FilledButton, 'Continue to study'));
      await tester.pumpAndSettle();

      expect(find.text('View recovery phrase'), findsNothing);
      expect(isPending, isFalse);
    },
  );
}
