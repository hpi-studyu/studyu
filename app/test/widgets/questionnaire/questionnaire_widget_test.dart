import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:studyu_app/l10n/app_localizations.dart';
import 'package:studyu_app/widgets/questionnaire/questionnaire_widget.dart';
import 'package:studyu_core/core.dart';

/// Snapshot of answer responses at callback time.
/// Using a Map copy avoids holding a reference to the mutable QuestionnaireState.
Map<String, Object?>? _snapshot(QuestionnaireState? state) {
  if (state == null) return null;
  return state.answers.map((key, value) => MapEntry(key, value.response));
}

Widget setup(Widget child) {
  return MaterialApp(
    theme: ThemeData(useMaterial3: false),
    supportedLocales: AppLocalizations.supportedLocales,
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    locale: const Locale('en'),
    home: Scaffold(body: child),
  );
}

void main() {
  testWidgets(
    'valid edit of completed non-last free text resets flow before resubmit',
    (tester) async {
      final q1 = FreeTextQuestion.withId(
        textType: FreeTextQuestionType.custom,
        lengthRange: [1, 100],
        customTypeExpression: r'\d+',
      )..id = 'q1';
      final q2 = FreeTextQuestion.withId(
        textType: FreeTextQuestionType.any,
        lengthRange: [1, 100],
      )..id = 'q2';

      final List<Map<String, Object?>?> snapshots = [];

      tester.view.physicalSize = const Size(800, 2000);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        setup(
          QuestionnaireWidget(
            [q1, q2],
            onComplete: (state) {
              snapshots.add(_snapshot(state));
            },
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextFormField).first, '2');
      await tester.pump();
      await tester.tap(find.text('Submit').first);
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextFormField).last, 'later');
      await tester.pump();
      await tester.tap(find.text('Submit').last);
      await tester.pumpAndSettle();

      final firstCompletion = snapshots.firstWhere((s) => s != null)!;
      expect(firstCompletion['q1'], '2');
      expect(firstCompletion['q2'], 'later');
      final completionCountBeforeEdit = snapshots
          .where((s) => s != null)
          .length;

      await tester.enterText(find.byType(TextFormField).first, '23');
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 350));
      await tester.pumpAndSettle();

      expect(
        snapshots.where((s) => s == null).length,
        equals(1),
        reason: 'valid non-last edit should invalidate completed questionnaire',
      );
      expect(
        snapshots.where((s) => s != null).length,
        equals(completionCountBeforeEdit),
        reason: 'stale q1 answer should not complete again',
      );
      expect(find.byType(TextFormField), findsOneWidget);
      expect(find.text('Submit'), findsOneWidget);

      await tester.tap(find.text('Submit'));
      await tester.pumpAndSettle();

      expect(find.byType(TextFormField), findsNWidgets(2));

      await tester.enterText(find.byType(TextFormField).last, 'later again');
      await tester.pump();
      await tester.tap(find.text('Submit').last);
      await tester.pumpAndSettle();

      final finalCompletion = snapshots.where((s) => s != null).last!;
      expect(finalCompletion['q1'], '23');
      expect(finalCompletion['q2'], 'later again');
    },
  );

  testWidgets(
    'invalidating a non-final question fires null callback exactly once, '
    'valid edits wait for explicit submit when question is not last',
    (tester) async {
      final q1 = FreeTextQuestion.withId(
        textType: FreeTextQuestionType.custom,
        lengthRange: [1, 100],
        customTypeExpression: r'\d+',
      )..id = 'q1';
      final q2 = FreeTextQuestion.withId(
        textType: FreeTextQuestionType.any,
        lengthRange: [1, 100],
      )..id = 'q2';
      final q3 = FreeTextQuestion.withId(
        textType: FreeTextQuestionType.any,
        lengthRange: [1, 100],
      )..id = 'q3';

      /// Snapshots recording what was passed to onComplete.
      /// null snapshot means invalidation, non-null means completion.
      final List<Map<String, Object?>?> snapshots = [];

      // Set a fixed surface size so the AnimatedList has layout space
      tester.view.physicalSize = const Size(800, 2000);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        setup(
          QuestionnaireWidget(
            [q1, q2, q3],
            onComplete: (state) {
              snapshots.add(_snapshot(state));
            },
          ),
        ),
      );
      await tester.pumpAndSettle();

      // --- Answer Q1="123", Q2="second", Q3="third" via Submit button ---
      await tester.enterText(find.byType(TextFormField).first, '123');
      await tester.pump();
      await tester.tap(find.text('Submit').first);
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextFormField).last, 'second');
      await tester.pump();
      await tester.tap(find.text('Submit').last);
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextFormField).last, 'third');
      await tester.pump();
      await tester.tap(find.text('Submit').last);
      await tester.pumpAndSettle();

      // Expect first completion with all 3 answers
      expect(snapshots.length, greaterThanOrEqualTo(1));
      final firstCompletion = snapshots.firstWhere((s) => s != null);
      expect(firstCompletion, isNotNull);
      expect(firstCompletion!['q1'], '123');
      expect(firstCompletion['q2'], 'second');
      expect(firstCompletion['q3'], 'third');

      // Record count of non-null completions so far
      final nonNullCountBeforeInvalid = snapshots
          .where((s) => s != null)
          .length;

      // --- Invalidate Q1 by entering "abc" → trigger debounce ---
      await tester.enterText(find.byType(TextFormField).first, 'abc');
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 350));
      await tester.pump();

      // Assert exactly one null snapshot for invalidation
      final nullSnapshots = snapshots.where((s) => s == null).toList();
      expect(
        nullSnapshots.length,
        equals(1),
        reason: 'invalidation should fire null callback exactly once',
      );

      // Non-null count should be unchanged
      expect(
        snapshots.where((s) => s != null).length,
        equals(nonNullCountBeforeInvalid),
        reason:
            'non-null completion count should not change after invalidation',
      );

      // --- Trigger another invalid cycle (still invalid "abc" → "xyz") ---
      await tester.enterText(find.byType(TextFormField).first, 'xyz');
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 350));
      await tester.pump();

      // No duplicate null
      expect(
        snapshots.where((s) => s == null).length,
        equals(1),
        reason: 'no duplicate null invalidation when still invalid',
      );

      // --- Correct Q1 to valid "456" via debounce ---
      await tester.enterText(find.byType(TextFormField).first, '456');
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 350));
      await tester.pump();

      // Valid edit is not auto-submitted while Q1 is not the last visible
      // question, so completion stays invalid until explicit Submit is possible.
      final completionsAfterFix = snapshots.where((s) => s != null).toList();
      expect(
        completionsAfterFix.length,
        equals(nonNullCountBeforeInvalid),
        reason: 'non-last valid edit should not re-complete via debounce',
      );

      final lastCompletion = completionsAfterFix.last;
      expect(lastCompletion!['q1'], '123');
      expect(lastCompletion['q2'], 'second');
      expect(lastCompletion['q3'], 'third');

      // Still exactly one null invalidation
      expect(
        snapshots.where((s) => s == null).length,
        equals(1),
        reason: 'total invalidation count should remain 1',
      );
    },
  );
}
