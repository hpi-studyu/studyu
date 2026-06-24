import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:studyu_app/l10n/app_localizations.dart';
import 'package:studyu_app/widgets/questionnaire/questions/free_text_question_widget.dart';
import 'package:studyu_core/core.dart';

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
  testWidgets('after valid submit, invalid edit calls onInvalid once, '
      'repeated invalid does not duplicate, valid edit resubmits via debounce', (
    tester,
  ) async {
    final question = FreeTextQuestion.withId(
      textType: FreeTextQuestionType.custom,
      lengthRange: [1, 10],
      customTypeExpression: r'\d+',
    );

    int onDoneCount = 0;
    int onInvalidCount = 0;
    Answer<String>? lastAnswer;

    await tester.pumpWidget(
      setup(
        FreeTextQuestionWidget(
          question: question,
          onDone: (answer) {
            onDoneCount++;
            lastAnswer = answer as Answer<String>;
          },
          onInvalid: () {
            onInvalidCount++;
          },
        ),
      ),
    );
    await tester.pumpAndSettle();

    // --- Step 1: submit valid "123" via explicit Submit button ---
    await tester.enterText(find.byType(TextFormField), '123');
    await tester.pump();
    await tester.tap(find.text('Submit'));
    await tester.pumpAndSettle();

    expect(onDoneCount, equals(1), reason: 'valid submit should call onDone');
    expect(lastAnswer?.response, equals('123'));
    expect(onInvalidCount, equals(0));

    // --- Step 2: edit to invalid "abc" → onInvalid once via debounce ---
    await tester.enterText(find.byType(TextFormField), 'abc');
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 350));
    await tester.pump();

    expect(
      onInvalidCount,
      equals(1),
      reason: 'valid→invalid should call onInvalid once',
    );
    expect(
      onDoneCount,
      equals(1),
      reason: 'onDone should not be called for invalid',
    );

    // --- Step 3: edit to another invalid value "xyz" → NO extra onInvalid ---
    await tester.enterText(find.byType(TextFormField), 'xyz');
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 350));
    await tester.pump();

    expect(
      onInvalidCount,
      equals(1),
      reason: 'repeated invalid should NOT call onInvalid again',
    );
    expect(onDoneCount, equals(1));

    // --- Step 4: edit back to valid "456" → onDone resubmits via debounce ---
    await tester.enterText(find.byType(TextFormField), '456');
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 350));
    await tester.pump();

    expect(
      onDoneCount,
      equals(2),
      reason: 'invalid→valid should resubmit via debounce',
    );
    expect(lastAnswer?.response, equals('456'));
    expect(onInvalidCount, equals(1));
  });

  testWidgets(
    'non-last submitted answer invalidates once but does not resubmit valid edits',
    (tester) async {
      final question = FreeTextQuestion.withId(
        textType: FreeTextQuestionType.custom,
        lengthRange: [1, 10],
        customTypeExpression: r'\d+',
      );

      int onDoneCount = 0;
      int onInvalidCount = 0;
      Answer<String>? lastAnswer;

      Widget build({required bool isLastQuestion}) {
        return setup(
          FreeTextQuestionWidget(
            question: question,
            isLastQuestion: isLastQuestion,
            onDone: (answer) {
              onDoneCount++;
              lastAnswer = answer as Answer<String>;
            },
            onInvalid: () {
              onInvalidCount++;
            },
          ),
        );
      }

      await tester.pumpWidget(build(isLastQuestion: true));
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextFormField), '123');
      await tester.pump();
      await tester.tap(find.text('Submit'));
      await tester.pumpAndSettle();

      expect(onDoneCount, equals(1));
      expect(lastAnswer?.response, equals('123'));

      await tester.pumpWidget(build(isLastQuestion: false));
      await tester.pumpAndSettle();

      expect(find.text('Submit'), findsNothing);

      await tester.enterText(find.byType(TextFormField), 'abc');
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 350));
      await tester.pump();

      expect(onInvalidCount, equals(1));
      expect(onDoneCount, equals(1));

      await tester.enterText(find.byType(TextFormField), 'xyz');
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 350));
      await tester.pump();

      expect(onInvalidCount, equals(1));
      expect(onDoneCount, equals(1));

      await tester.enterText(find.byType(TextFormField), '456');
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 350));
      await tester.pump();

      expect(onInvalidCount, equals(1));
      expect(
        onDoneCount,
        equals(2),
        reason: 'non-conditional invalid→valid should resync via debounce',
      );
      expect(lastAnswer?.response, equals('456'));
    },
  );

  testWidgets(
    'non-last valid edit after submit syncs via debounce without invalidation',
    (tester) async {
      final question = FreeTextQuestion.withId(
        textType: FreeTextQuestionType.custom,
        lengthRange: [1, 10],
        customTypeExpression: r'\d+',
      );

      int onDoneCount = 0;
      int onInvalidCount = 0;
      Answer<String>? lastAnswer;

      Widget build({required bool isLastQuestion}) {
        return setup(
          FreeTextQuestionWidget(
            question: question,
            isLastQuestion: isLastQuestion,
            onDone: (answer) {
              onDoneCount++;
              lastAnswer = answer as Answer<String>;
            },
            onInvalid: () {
              onInvalidCount++;
            },
          ),
        );
      }

      await tester.pumpWidget(build(isLastQuestion: true));
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextFormField), '2');
      await tester.pump();
      await tester.tap(find.text('Submit'));
      await tester.pumpAndSettle();

      expect(onDoneCount, equals(1));
      expect(lastAnswer?.response, equals('2'));
      expect(onInvalidCount, equals(0));

      await tester.pumpWidget(build(isLastQuestion: false));
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextFormField), '23');
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 350));
      await tester.pump();

      // Non-conditional non-last valid edit: syncs via onDone, not onInvalid.
      expect(onInvalidCount, equals(0));
      expect(onDoneCount, equals(2));
      expect(lastAnswer?.response, equals('23'));

      await tester.enterText(find.byType(TextFormField), '234');
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 350));
      await tester.pump();

      // Another sync.
      expect(onInvalidCount, equals(0));
      expect(onDoneCount, equals(3));
      expect(lastAnswer?.response, equals('234'));
    },
  );

  testWidgets('keyboard done does not submit hidden non-last free text field', (
    tester,
  ) async {
    final question = FreeTextQuestion.withId(
      textType: FreeTextQuestionType.custom,
      lengthRange: [1, 10],
      customTypeExpression: r'\d+',
    );

    int onDoneCount = 0;
    int onInvalidCount = 0;
    Answer<String>? lastAnswer;

    Widget build({required bool isLastQuestion}) {
      return setup(
        FreeTextQuestionWidget(
          question: question,
          isLastQuestion: isLastQuestion,
          onDone: (answer) {
            onDoneCount++;
            lastAnswer = answer as Answer<String>;
          },
          onInvalid: () {
            onInvalidCount++;
          },
        ),
      );
    }

    await tester.pumpWidget(build(isLastQuestion: true));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextFormField), '123');
    await tester.pump();
    await tester.tap(find.text('Submit'));
    await tester.pumpAndSettle();

    expect(onDoneCount, equals(1));
    expect(lastAnswer?.response, equals('123'));
    expect(onInvalidCount, equals(0));

    await tester.pumpWidget(build(isLastQuestion: false));
    await tester.pumpAndSettle();

    expect(find.text('Submit'), findsNothing);

    await tester.enterText(find.byType(TextFormField), '456');
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 350));
    await tester.pump();

    // Non-conditional non-last valid edit syncs via onDone, not onInvalid.
    expect(onInvalidCount, equals(0));
    expect(onDoneCount, equals(2));
    expect(lastAnswer?.response, equals('456'));

    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pumpAndSettle();

    expect(
      onDoneCount,
      equals(2),
      reason: 'keyboard Done must not submit hidden non-last field',
    );
    expect(onInvalidCount, equals(0));
    expect(lastAnswer?.response, equals('456'));
  });

  testWidgets('Submit button is hidden when not last question', (tester) async {
    final question = FreeTextQuestion.withId(
      textType: FreeTextQuestionType.any,
      lengthRange: [1, 10],
    );

    await tester.pumpWidget(setup(FreeTextQuestionWidget(question: question)));
    await tester.pumpAndSettle();

    expect(find.text('Submit'), findsOneWidget);

    await tester.pumpWidget(
      setup(FreeTextQuestionWidget(question: question, isLastQuestion: false)),
    );
    await tester.pumpAndSettle();

    expect(find.text('Submit'), findsNothing);
  });

  testWidgets(
    'initial valid typing does NOT call onDone via debounce before explicit submit',
    (tester) async {
      final question = FreeTextQuestion.withId(
        textType: FreeTextQuestionType.custom,
        lengthRange: [1, 10],
        customTypeExpression: r'\d+',
      );

      int onDoneCount = 0;
      int onInvalidCount = 0;

      await tester.pumpWidget(
        setup(
          FreeTextQuestionWidget(
            question: question,
            onDone: (_) => onDoneCount++,
            onInvalid: () => onInvalidCount++,
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Type valid text — without tapping Submit or blurring
      await tester.enterText(find.byType(TextFormField), '123');
      await tester.pump();
      // Wait past debounce delay (300ms)
      await tester.pump(const Duration(milliseconds: 350));
      await tester.pump();

      // Should NOT have called onDone or onInvalid via debounce alone
      expect(
        onDoneCount,
        equals(0),
        reason: 'onDone should not fire from debounce before first submit',
      );
      expect(onInvalidCount, equals(0));

      // Now tap Submit — should call onDone
      await tester.tap(find.text('Submit'));
      await tester.pumpAndSettle();

      expect(
        onDoneCount,
        equals(1),
        reason: 'onDone should fire after explicit Submit',
      );
    },
  );

  testWidgets('custom regex ignores hidden length range validation', (
    tester,
  ) async {
    final question = FreeTextQuestion.withId(
      textType: FreeTextQuestionType.custom,
      lengthRange: [10, 50],
      customTypeExpression: r'\d+',
    );

    Answer<String>? lastAnswer;

    await tester.pumpWidget(
      setup(
        FreeTextQuestionWidget(
          question: question,
          onDone: (answer) {
            lastAnswer = answer as Answer<String>;
          },
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextFormField), '12');
    await tester.pump();
    await tester.tap(find.text('Submit'));
    await tester.pumpAndSettle();

    expect(lastAnswer?.response, equals('12'));
    expect(find.text('Please enter at least 10 characters'), findsNothing);
  });

  testWidgets(
    'malformed custom regex shows generic error and logs diagnostic',
    (tester) async {
      final question = FreeTextQuestion.withId(
        textType: FreeTextQuestionType.custom,
        lengthRange: [1, 10],
        customTypeExpression: '[',
      );

      final debugMessages = <String>[];
      final originalDebugPrint = debugPrint;
      debugPrint = (String? message, {int? wrapWidth}) {
        debugMessages.add(message ?? '');
      };
      addTearDown(() {
        debugPrint = originalDebugPrint;
      });

      try {
        int onDoneCount = 0;

        await tester.pumpWidget(
          setup(
            FreeTextQuestionWidget(
              question: question,
              onDone: (_) => onDoneCount++,
            ),
          ),
        );
        await tester.pumpAndSettle();

        await tester.enterText(find.byType(TextFormField), 'abc');
        await tester.pump();
        await tester.tap(find.text('Submit'));
        await tester.pumpAndSettle();

        expect(onDoneCount, equals(0));
        expect(
          find.text('Please enter a value in the required format'),
          findsOneWidget,
        );
        expect(
          debugMessages,
          contains(
            allOf(
              contains('Invalid custom regex for free text question'),
              contains(question.id),
              contains('FormatException'),
            ),
          ),
        );
      } finally {
        debugPrint = originalDebugPrint;
      }
    },
  );

  testWidgets('non-custom length errors block onDone', (tester) async {
    final question = FreeTextQuestion.withId(
      textType: FreeTextQuestionType.any,
      lengthRange: [3, 5],
    );

    int onDoneCount = 0;

    await tester.pumpWidget(
      setup(
        FreeTextQuestionWidget(
          question: question,
          onDone: (_) => onDoneCount++,
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextFormField), 'ab');
    await tester.pump();
    await tester.tap(find.text('Submit'));
    await tester.pumpAndSettle();

    expect(onDoneCount, equals(0));
    expect(find.text('Please enter at least 3 characters'), findsOneWidget);

    await tester.enterText(find.byType(TextFormField), 'abcdef');
    await tester.pump();
    await tester.tap(find.text('Submit'));
    await tester.pumpAndSettle();

    expect(onDoneCount, equals(0));
    expect(find.text('Please enter at most 5 characters'), findsOneWidget);
  });
}
