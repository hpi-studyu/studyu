import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:studyu_app/l10n/app_localizations.dart';
import 'package:studyu_app/widgets/questionnaire/image_capturing_question_widget.dart';
import 'package:studyu_app/widgets/questionnaire/questionnaire_widget.dart';
import 'package:studyu_app/widgets/questionnaire/questions/date_question_widget.dart';
import 'package:studyu_app/widgets/selectable_button.dart';
import 'package:studyu_core/core.dart';

/// Snapshot of answer responses at callback time.
/// Using a Map copy avoids holding a reference to the mutable QuestionnaireState.
Map<String, Object?>? _snapshot(QuestionnaireState? state) {
  if (state == null) return null;
  return state.answers.map((key, value) => MapEntry(key, value.response));
}

void _expectSelectableButtonSelected(Finder childFinder) {
  final buttonFinder = find.ancestor(
    of: childFinder,
    matching: find.byType(SelectableButton),
  );
  expect(buttonFinder, findsOneWidget);
  expect(testerWidget<SelectableButton>(buttonFinder).selected, isTrue);
}

T testerWidget<T extends Widget>(Finder finder) {
  final element = finder.evaluate().single;
  return element.widget as T;
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

BooleanQuestion _boolQuestion(String id, String prompt) {
  return BooleanQuestion.withId()
    ..id = id
    ..prompt = prompt;
}

ChoiceQuestion _singleChoiceQuestion(String id, String prompt) {
  return ChoiceQuestion.withId()
    ..choices = [Choice.withId()..text = 'A', Choice.withId()..text = 'B']
    ..multiple = false
    ..id = id
    ..prompt = prompt;
}

ChoiceQuestion _multiChoiceQuestion(String id, String prompt) {
  return ChoiceQuestion.withId()
    ..choices = [Choice.withId()..text = 'A', Choice.withId()..text = 'B']
    ..multiple = true
    ..id = id
    ..prompt = prompt;
}

class RequiresBoolAnswerExpression extends Expression {
  RequiresBoolAnswerExpression({required this.target, required this.expected})
    : super('test-requires-bool-answer');

  final String target;
  final bool expected;
  final List<bool?> observedValues = [];

  @override
  bool? evaluate(QuestionnaireState state) {
    final hasAnswer = state.hasAnswer<bool>(target);
    final value = hasAnswer ? state.getAnswer<bool>(target) : null;
    observedValues.add(value);
    return value == expected;
  }

  @override
  Map<String, dynamic> toJson() => <String, dynamic>{'type': type};
}

void main() {
  testWidgets(
    'hidden conditional answers are excluded while hidden and restored when shown again',
    (tester) async {
      final q1 = _boolQuestion('q1', 'Show follow-up?');
      final q2 = _singleChoiceQuestion('q2', 'Pick one')
        ..conditional = QuestionConditional.withCondition(
          CompositeExpression(
            logicType: LogicType.and,
            expressions: [BooleanExpression()..target = 'q1'],
          ),
        );
      final q2ChoiceAId = q2.choices.first.id;

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

      await tester.tap(find.text('yes'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('A'));
      await tester.pumpAndSettle();

      final firstCompletion = snapshots.where((s) => s != null).last!;
      expect(firstCompletion['q1'], isTrue);
      expect(firstCompletion['q2'], [q2ChoiceAId]);

      await tester.tap(find.text('no'));
      await tester.pumpAndSettle();

      _expectSelectableButtonSelected(find.text('no'));
      expect(find.text('A'), findsNothing);
      final hiddenCompletion = snapshots.where((s) => s != null).last!;
      expect(hiddenCompletion['q1'], isFalse);
      expect(hiddenCompletion.containsKey('q2'), isFalse);

      await tester.tap(find.text('yes'));
      await tester.pumpAndSettle();
      await tester.pump(const Duration(milliseconds: 500));
      await tester.pumpAndSettle();

      final restoredCompletion = snapshots.where((s) => s != null).last!;
      expect(restoredCompletion['q2'], [q2ChoiceAId]);
      expect(restoredCompletion['q1'], isTrue);
      expect(find.text('A'), findsOneWidget);
      _expectSelectableButtonSelected(find.text('yes'));
      _expectSelectableButtonSelected(find.text('A'));
    },
  );

  testWidgets(
    'hidden image answer is not restored as complete when shown again',
    (tester) async {
      final q1 = _boolQuestion('q1', 'Show image upload?');
      final q2 = ImageCapturingQuestion.withId()
        ..id = 'q2'
        ..prompt = 'Capture image'
        ..conditional = QuestionConditional.withCondition(
          CompositeExpression(
            logicType: LogicType.and,
            expressions: [BooleanExpression()..target = 'q1'],
          ),
        );
      final imageFile = FutureBlobFile('/tmp/photo.jpg', 'future-photo');

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

      await tester.tap(find.text('yes'));
      await tester.pumpAndSettle();
      expect(find.byType(ImageCapturingQuestionWidget), findsOneWidget);

      final widget = tester.widget<ImageCapturingQuestionWidget>(
        find.byType(ImageCapturingQuestionWidget),
      );
      widget.onDone!(q2.constructAnswer(imageFile));
      await tester.pumpAndSettle();

      final firstCompletion = snapshots.where((s) => s != null).last!;
      expect(firstCompletion['q1'], isTrue);
      expect(firstCompletion['q2'], same(imageFile));

      await tester.tap(find.text('no'));
      await tester.pumpAndSettle();

      expect(find.byType(ImageCapturingQuestionWidget), findsNothing);
      final hiddenCompletion = snapshots.where((s) => s != null).last!;
      expect(hiddenCompletion['q1'], isFalse);
      expect(hiddenCompletion.containsKey('q2'), isFalse);

      final nonNullCompletionCountBeforeReshow = snapshots
          .where((s) => s != null)
          .length;

      await tester.tap(find.text('yes'));
      await tester.pumpAndSettle();
      await tester.pump(const Duration(milliseconds: 500));
      await tester.pumpAndSettle();

      expect(find.byType(ImageCapturingQuestionWidget), findsOneWidget);
      expect(snapshots.last, isNull);
      expect(
        snapshots.where((s) => s != null).length,
        nonNullCompletionCountBeforeReshow,
      );
    },
  );

  testWidgets(
    'conditional reset runs before shouldContinue stops questionnaire',
    (tester) async {
      final q1 = _boolQuestion('q1', 'Show follow-up before stop?');
      final q2 = _singleChoiceQuestion('q2', 'Pick before stop')
        ..conditional = QuestionConditional.withCondition(
          CompositeExpression(
            logicType: LogicType.and,
            expressions: [BooleanExpression()..target = 'q1'],
          ),
        );
      final q2ChoiceAId = q2.choices.first.id;

      final List<Map<String, Object?>?> snapshots = [];
      final List<Map<String, Object?>?> predicateSnapshots = [];

      tester.view.physicalSize = const Size(800, 2000);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        setup(
          QuestionnaireWidget(
            [q1, q2],
            shouldContinue: (state) {
              predicateSnapshots.add(_snapshot(state));
              return state.answers['q1']?.response != false;
            },
            onComplete: (state) {
              snapshots.add(_snapshot(state));
            },
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('yes'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('A'));
      await tester.pumpAndSettle();

      final firstCompletion = snapshots.where((s) => s != null).last!;
      expect(firstCompletion['q1'], isTrue);
      expect(firstCompletion['q2'], [q2ChoiceAId]);

      await tester.tap(find.text('no'));
      await tester.pumpAndSettle();

      expect(find.text('A'), findsNothing);
      final stoppedCompletion = snapshots.where((s) => s != null).last!;
      expect(stoppedCompletion['q1'], isFalse);
      expect(stoppedCompletion.containsKey('q2'), isFalse);

      final stoppedPredicate = predicateSnapshots.last!;
      expect(stoppedPredicate['q1'], isFalse);
      expect(stoppedPredicate.containsKey('q2'), isFalse);
    },
  );

  testWidgets(
    'restored empty multi-choice answer remains confirmed when shown again',
    (tester) async {
      final q1 = _boolQuestion('q1', 'Show empty multi-choice?');
      final q2 = _multiChoiceQuestion('q2', 'Pick zero or more')
        ..conditional = QuestionConditional.withCondition(
          CompositeExpression(
            logicType: LogicType.and,
            expressions: [BooleanExpression()..target = 'q1'],
          ),
        );

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

      await tester.tap(find.text('yes'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Confirm selection'));
      await tester.pumpAndSettle();

      final firstCompletion = snapshots.where((s) => s != null).last!;
      expect(firstCompletion['q1'], isTrue);
      expect(firstCompletion['q2'], isEmpty);

      await tester.tap(find.text('no'));
      await tester.pumpAndSettle();
      expect(find.text('Pick zero or more'), findsNothing);

      await tester.tap(find.text('yes'));
      await tester.pumpAndSettle();
      await tester.pump(const Duration(milliseconds: 500));
      await tester.pumpAndSettle();

      final restoredCompletion = snapshots.where((s) => s != null).last!;
      expect(restoredCompletion['q1'], isTrue);
      expect(restoredCompletion['q2'], isEmpty);
      expect(find.text('Confirm selection'), findsNothing);
    },
  );

  testWidgets(
    'multiple restored conditional answers are included when shown again',
    (tester) async {
      final q1 = _boolQuestion('q1', 'Show follow-ups?');
      final q2 = _singleChoiceQuestion('q2', 'Pick q2')
        ..conditional = QuestionConditional.withCondition(
          CompositeExpression(
            logicType: LogicType.and,
            expressions: [BooleanExpression()..target = 'q1'],
          ),
        );
      final q3 = _singleChoiceQuestion('q3', 'Pick q3')
        ..conditional = QuestionConditional.withCondition(
          CompositeExpression(
            logicType: LogicType.and,
            expressions: [BooleanExpression()..target = 'q1'],
          ),
        );
      final q2ChoiceAId = q2.choices.first.id;
      final q3ChoiceBId = q3.choices.last.id;

      final List<Map<String, Object?>?> snapshots = [];

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

      await tester.tap(find.text('yes'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('A'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('B').last);
      await tester.pumpAndSettle();

      final firstCompletion = snapshots.where((s) => s != null).last!;
      expect(firstCompletion['q1'], isTrue);
      expect(firstCompletion['q2'], [q2ChoiceAId]);
      expect(firstCompletion['q3'], [q3ChoiceBId]);

      await tester.tap(find.text('no'));
      await tester.pumpAndSettle();

      final hiddenCompletion = snapshots.where((s) => s != null).last!;
      expect(hiddenCompletion['q1'], isFalse);
      expect(hiddenCompletion.containsKey('q2'), isFalse);
      expect(hiddenCompletion.containsKey('q3'), isFalse);

      await tester.tap(find.text('yes'));
      await tester.pumpAndSettle();
      await tester.pump(const Duration(milliseconds: 500));
      await tester.pumpAndSettle();

      final restoredCompletion = snapshots.where((s) => s != null).last!;
      expect(restoredCompletion['q1'], isTrue);
      expect(restoredCompletion['q2'], [q2ChoiceAId]);
      expect(restoredCompletion['q3'], [q3ChoiceBId]);
      _expectSelectableButtonSelected(find.text('yes'));
      _expectSelectableButtonSelected(find.text('A').first);
      _expectSelectableButtonSelected(find.text('B').last);
    },
  );

  testWidgets(
    'hidden default answer drives later condition but stays out of payload',
    (tester) async {
      final q1 = _boolQuestion('q1', 'Show skipped question?');
      final q2 = _boolQuestion('q2', 'Skipped default source')
        ..conditional = QuestionConditional.withCondition(
          CompositeExpression(
            logicType: LogicType.and,
            expressions: [BooleanExpression()..target = 'q1'],
          ),
          defaultValue: true,
        );
      final q3 = _singleChoiceQuestion('q3', 'Shown by q2 default')
        ..conditional = QuestionConditional.withCondition(
          CompositeExpression(
            logicType: LogicType.and,
            expressions: [BooleanExpression()..target = 'q2'],
          ),
        );
      final q3ChoiceAId = q3.choices.first.id;

      final List<Map<String, Object?>?> snapshots = [];

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

      await tester.tap(find.text('no'));
      await tester.pumpAndSettle();

      expect(find.text('A'), findsOneWidget);

      await tester.tap(find.text('A'));
      await tester.pumpAndSettle();

      final completion = snapshots.where((s) => s != null).last!;
      expect(completion['q1'], isFalse);
      expect(completion.containsKey('q2'), isFalse);
      expect(completion['q3'], [q3ChoiceAId]);
    },
  );

  testWidgets(
    'hidden default false finishes when no later questions stay visible',
    (tester) async {
      final q0 = _boolQuestion('q0', 'Show skipped question?');
      final q1 = _boolQuestion('q1', 'Last visible question');
      final q2 = _boolQuestion('q2', 'Skipped default source')
        ..conditional = QuestionConditional.withCondition(
          CompositeExpression(
            logicType: LogicType.and,
            expressions: [BooleanExpression()..target = 'q0'],
          ),
          defaultValue: false,
        );
      final q3 = _singleChoiceQuestion('q3', 'Hidden by q2 default')
        ..conditional = QuestionConditional.withCondition(
          CompositeExpression(
            logicType: LogicType.and,
            expressions: [BooleanExpression()..target = 'q2'],
          ),
        );

      final List<Map<String, Object?>?> snapshots = [];

      tester.view.physicalSize = const Size(800, 2000);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        setup(
          QuestionnaireWidget(
            [q0, q1, q2, q3],
            onComplete: (state) {
              snapshots.add(_snapshot(state));
            },
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('no'));
      await tester.pumpAndSettle();
      expect(snapshots.where((s) => s != null), isEmpty);

      await tester.tap(find.text('no').last);
      await tester.pumpAndSettle();

      expect(find.text('Skipped default source'), findsNothing);
      expect(find.text('Hidden by q2 default'), findsNothing);
      final completion = snapshots.where((s) => s != null).lastOrNull;
      expect(completion, isNotNull);
      expect(completion!['q0'], isFalse);
      expect(completion['q1'], isFalse);
      expect(completion.containsKey('q2'), isFalse);
      expect(completion.containsKey('q3'), isFalse);
    },
  );

  testWidgets(
    'normal progression applies hidden default before deciding completion',
    (tester) async {
      final q0 = _boolQuestion('q0', 'Hide default branch?');
      final q1 = _singleChoiceQuestion('q1', 'Visible bridge question')
        ..choices[0].text = 'Bridge A'
        ..choices[1].text = 'Bridge B';
      final q2 = _boolQuestion('q2', 'Hidden default source')
        ..conditional = QuestionConditional.withCondition(
          CompositeExpression(
            logicType: LogicType.and,
            expressions: [BooleanExpression()..target = 'q0'],
          ),
          defaultValue: true,
        );
      final q3Expression = RequiresBoolAnswerExpression(
        target: 'q2',
        expected: true,
      );
      final q3 = _singleChoiceQuestion('q3', 'Shown by hidden default')
        ..choices[0].text = 'Follow A'
        ..choices[1].text = 'Follow B'
        ..conditional = QuestionConditional.withCondition(
          CompositeExpression(
            logicType: LogicType.and,
            expressions: [q3Expression],
          ),
        );
      final q1ChoiceAId = q1.choices.first.id;
      final q3ChoiceBId = q3.choices.last.id;

      final List<Map<String, Object?>?> snapshots = [];

      tester.view.physicalSize = const Size(800, 2000);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        setup(
          QuestionnaireWidget(
            [q0, q1, q2, q3],
            onComplete: (state) {
              snapshots.add(_snapshot(state));
            },
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('no'));
      await tester.pumpAndSettle();
      expect(snapshots.where((s) => s != null), isEmpty);
      expect(find.text('Bridge A'), findsOneWidget);

      await tester.tap(find.text('Bridge A'));
      await tester.pumpAndSettle();

      expect(snapshots.where((s) => s != null), isEmpty);
      expect(find.text('Hidden default source'), findsNothing);
      expect(find.text('Follow B'), findsOneWidget);
      expect(q3Expression.observedValues.contains(true), isTrue);

      await tester.tap(find.text('Follow B'));
      await tester.pumpAndSettle();

      final completion = snapshots.where((s) => s != null).last!;
      expect(completion['q0'], isFalse);
      expect(completion['q1'], [q1ChoiceAId]);
      expect(completion.containsKey('q2'), isFalse);
      expect(completion['q3'], [q3ChoiceBId]);
    },
  );

  testWidgets(
    'normal progression completes when restored final question is already answered',
    (tester) async {
      final questionnaireKey = GlobalKey<QuestionnaireWidgetState>();
      final q1 = FreeTextQuestion.withId(
        textType: FreeTextQuestionType.custom,
        lengthRange: [1, 100],
        customTypeExpression: r'\d+',
      )..id = 'q1';
      final q2 = _singleChoiceQuestion('q2', 'Cached final question');
      final q2ChoiceAId = q2.choices.first.id;

      final List<Map<String, Object?>?> snapshots = [];

      tester.view.physicalSize = const Size(800, 2000);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        setup(
          QuestionnaireWidget(
            [q1, q2],
            key: questionnaireKey,
            onComplete: (state) {
              snapshots.add(_snapshot(state));
            },
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextFormField).first, '1');
      await tester.pump();
      await tester.tap(find.text('Submit').first);
      await tester.pumpAndSettle();
      await tester.tap(find.text('A'));
      await tester.pumpAndSettle();

      final firstCompletion = snapshots.where((s) => s != null).last!;
      expect(firstCompletion['q1'], '1');
      expect(firstCompletion['q2'], [q2ChoiceAId]);
      final completionCountBeforeInvalidation = snapshots
          .where((s) => s != null)
          .length;

      // Invalidate Q1 with non-digit text. Q2 stays visible (non-conditional).
      await tester.enterText(find.byType(TextFormField).first, 'invalid');
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 350));
      await tester.pumpAndSettle();
      await tester.pump();
      await tester.pumpAndSettle();

      // Q1 invalidated, Q2 stays visible (non-conditional). Null callback emitted.
      expect(snapshots.where((s) => s == null).length, 1);

      // Correct Q1 to valid. Non-last, _hasSubmitted=false after invalidation,
      // so no auto-sync. Use Complete validation/sync to finish.
      await tester.enterText(find.byType(TextFormField).first, '2');
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 350));
      await tester.pump();
      await tester.pumpAndSettle();
      await tester.pump(const Duration(milliseconds: 600));

      // Non-conditional correction syncs via debounce and re-completes.
      final completions = snapshots.where((s) => s != null).toList();
      expect(completions.length, completionCountBeforeInvalidation + 1);
      final restoredCompletion = completions.last!;
      expect(restoredCompletion['q1'], '2');
      expect(restoredCompletion['q2'], [q2ChoiceAId]);
      _expectSelectableButtonSelected(find.text('A'));
    },
  );

  testWidgets(
    'shouldContinue stops before newly visible conditional follow-up is shown',
    (tester) async {
      final q1 = _boolQuestion('q1', 'Reveal follow-up but stop?');
      final q2 = _singleChoiceQuestion('q2', 'Should stay hidden')
        ..conditional = QuestionConditional.withCondition(
          CompositeExpression(
            logicType: LogicType.and,
            expressions: [BooleanExpression()..target = 'q1'],
          ),
        );

      final List<Map<String, Object?>?> snapshots = [];

      tester.view.physicalSize = const Size(800, 2000);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        setup(
          QuestionnaireWidget(
            [q1, q2],
            shouldContinue: (_) => false,
            onComplete: (state) {
              snapshots.add(_snapshot(state));
            },
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('yes'));
      await tester.pumpAndSettle();

      expect(find.text('Should stay hidden'), findsNothing);
      expect(find.text('A'), findsNothing);
      expect(snapshots.where((s) => s != null), isNotEmpty);
      expect(snapshots.where((s) => s != null).last!['q1'], isTrue);
    },
  );

  testWidgets('validate sync payload uses latest visible free text edits', (
    tester,
  ) async {
    final questionnaireKey = GlobalKey<QuestionnaireWidgetState>();
    final q1 = FreeTextQuestion.withId(
      textType: FreeTextQuestionType.custom,
      lengthRange: [1, 100],
      customTypeExpression: r'\d+',
    )..id = 'q1';
    final q2 = FreeTextQuestion.withId(
      textType: FreeTextQuestionType.any,
      lengthRange: [1, 100],
    )..id = 'q2';

    tester.view.physicalSize = const Size(800, 2000);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      setup(QuestionnaireWidget([q1, q2], key: questionnaireKey)),
    );
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextFormField).first, '2');
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 350));
    await tester.pump();
    await tester.pumpAndSettle();
    await tester.tap(find.text('Submit').first);
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextFormField).last, 'later');
    await tester.pump();
    await tester.tap(find.text('Submit').last);
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextFormField).first, '23');
    await tester.pump();

    final payload = questionnaireKey.currentState!
        .validateSyncAndBuildPayload();
    await tester.pumpAndSettle();

    expect(payload, isNotNull);
    expect(payload!.answers.keys, unorderedEquals(['q1', 'q2']));
    expect(payload.answers['q1']!.response, '23');
    expect(payload.answers['q2']!.response, 'later');
    await tester.pump(const Duration(milliseconds: 500));
  });

  testWidgets(
    'validate sync payload returns null and shows error for invalid visible free text',
    (tester) async {
      final questionnaireKey = GlobalKey<QuestionnaireWidgetState>();
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
            key: questionnaireKey,
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

      final validCompletion = snapshots.where((s) => s != null).last!;
      expect(validCompletion['q1'], '2');
      expect(validCompletion['q2'], 'later');
      final snapshotCountBeforeInvalidComplete = snapshots.length;

      await tester.enterText(find.byType(TextFormField).first, 'bad');
      await tester.pump();

      final payload = questionnaireKey.currentState!
          .validateSyncAndBuildPayload();
      await tester.pumpAndSettle();

      expect(payload, isNull);
      expect(snapshots.length, snapshotCountBeforeInvalidComplete);
      expect(snapshots.where((s) => s != null).last, validCompletion);
      expect(snapshots.where((s) => s == null), isEmpty);
      expect(
        find.text('Please enter a value in the required format'),
        findsOneWidget,
      );

      await tester.enterText(find.byType(TextFormField).first, '3');
      await tester.pump();
      final correctedPayload = questionnaireKey.currentState!
          .validateSyncAndBuildPayload();
      expect(correctedPayload, isNotNull);
      expect(correctedPayload!.answers['q1']!.response, '3');
      expect(correctedPayload.answers['q2']!.response, 'later');
      await tester.pump(const Duration(milliseconds: 500));
    },
  );

  testWidgets(
    'validate sync payload is atomic when one visible free text is invalid',
    (tester) async {
      final questionnaireKey = GlobalKey<QuestionnaireWidgetState>();
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
            key: questionnaireKey,
            onComplete: (state) {
              snapshots.add(_snapshot(state));
            },
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextFormField).first, '1');
      await tester.pump();
      await tester.tap(find.text('Submit').first);
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextFormField).last, 'old q2');
      await tester.pump();
      await tester.tap(find.text('Submit').last);
      await tester.pumpAndSettle();

      final validCompletion = snapshots.where((s) => s != null).last!;
      expect(validCompletion['q1'], '1');
      expect(validCompletion['q2'], 'old q2');
      final snapshotCountBeforeInvalidComplete = snapshots.length;

      await tester.enterText(find.byType(TextFormField).first, 'bad');
      await tester.pump();
      await tester.enterText(find.byType(TextFormField).last, 'new q2');
      await tester.pump();

      final payload = questionnaireKey.currentState!
          .validateSyncAndBuildPayload();
      await tester.pumpAndSettle();

      expect(payload, isNull);
      expect(snapshots.length, snapshotCountBeforeInvalidComplete);
      expect(snapshots.where((s) => s != null).last, validCompletion);
      expect(snapshots.where((s) => s == null), isEmpty);

      await tester.enterText(find.byType(TextFormField).first, '2');
      await tester.pump();
      final correctedPayload = questionnaireKey.currentState!
          .validateSyncAndBuildPayload();
      expect(correctedPayload, isNotNull);
      expect(correctedPayload!.answers['q1']!.response, '2');
      expect(correctedPayload.answers['q2']!.response, 'new q2');
      await tester.pump(const Duration(milliseconds: 500));
    },
  );

  testWidgets(
    'complete sync does not apply conditional non-last free text branch edits',
    (tester) async {
      final questionnaireKey = GlobalKey<QuestionnaireWidgetState>();
      final q1 = FreeTextQuestion.withId(
        textType: FreeTextQuestionType.any,
        lengthRange: [1, 100],
      )..id = 'q1';
      final q2 =
          FreeTextQuestion.withId(
              textType: FreeTextQuestionType.any,
              lengthRange: [1, 100],
            )
            ..id = 'q2'
            ..conditional = QuestionConditional.withCondition(
              CompositeExpression(
                logicType: LogicType.and,
                expressions: [
                  TextExpression(
                    comparator: TextComparator.equal,
                    value: 'show',
                  )..target = 'q1',
                ],
              ),
            );

      final List<Map<String, Object?>?> snapshots = [];

      tester.view.physicalSize = const Size(800, 2000);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        setup(
          QuestionnaireWidget(
            [q1, q2],
            key: questionnaireKey,
            onComplete: (state) {
              snapshots.add(_snapshot(state));
            },
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextFormField).first, 'show');
      await tester.pump();
      await tester.tap(find.text('Submit').first);
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextFormField).last, 'dependent');
      await tester.pump();
      await tester.tap(find.text('Submit').last);
      await tester.pumpAndSettle();

      final validCompletion = snapshots.where((s) => s != null).last!;
      expect(validCompletion['q1'], 'show');
      expect(validCompletion['q2'], 'dependent');
      final snapshotCountBeforeCompleteSync = snapshots.length;
      final nullSnapshotCountBeforeCompleteSync = snapshots
          .where((s) => s == null)
          .length;

      await tester.enterText(find.byType(TextFormField).first, 'hide');
      await tester.pump();

      final payload = questionnaireKey.currentState!
          .validateSyncAndBuildPayload();

      expect(payload, isNotNull);
      expect(payload!.answers['q1']!.response, 'show');
      expect(payload.answers['q2']!.response, 'dependent');
      expect(find.text('dependent'), findsOneWidget);
      expect(snapshots.length, snapshotCountBeforeCompleteSync);
      expect(snapshots.where((s) => s != null).last, validCompletion);
      expect(
        snapshots.where((s) => s == null).length,
        nullSnapshotCountBeforeCompleteSync,
      );
      await tester.pump(const Duration(milliseconds: 500));
    },
  );

  testWidgets(
    'non-conditional valid-to-valid edit syncs via debounce, keeps later questions visible',
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

      // Edit Q1 valid-to-valid: syncs by debounce, no invalidation, Q2 stays.
      await tester.enterText(find.byType(TextFormField).first, '23');
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 350));
      await tester.pumpAndSettle();

      // No null callback emitted for non-conditional valid edit.
      expect(snapshots.where((s) => s == null), isEmpty);

      // Both questions remain visible.
      expect(find.byType(TextFormField), findsNWidgets(2));

      // Submit visible only for last question (Q2). Q1 Submit stays hidden.
      expect(find.text('Submit'), findsOneWidget);

      // Completion synced q1 new value, q2 unchanged.
      final syncedCompletion = snapshots.where((s) => s != null).last!;
      expect(syncedCompletion['q1'], '23');
      expect(syncedCompletion['q2'], 'later');

      // Pump past _ensureTextFieldVisible timer to avoid leak.
      await tester.pump(const Duration(milliseconds: 600));
    },
  );

  testWidgets(
    'conditional non-last valid edit shows Submit and waits for explicit submission',
    (tester) async {
      final q1 = FreeTextQuestion.withId(
        textType: FreeTextQuestionType.any,
        lengthRange: [1, 100],
      )..id = 'q1';
      final q2 =
          FreeTextQuestion.withId(
              textType: FreeTextQuestionType.any,
              lengthRange: [1, 100],
            )
            ..id = 'q2'
            ..conditional = QuestionConditional.withCondition(
              CompositeExpression(
                logicType: LogicType.and,
                expressions: [
                  TextExpression(
                    comparator: TextComparator.equal,
                    value: 'show',
                  )..target = 'q1',
                ],
              ),
            );

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

      await tester.enterText(find.byType(TextFormField).first, 'show');
      await tester.pump();
      await tester.tap(find.text('Submit').first);
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextFormField).last, 'dependent');
      await tester.pump();
      await tester.tap(find.text('Submit').last);
      await tester.pumpAndSettle();

      final firstCompletion = snapshots.where((s) => s != null).last!;
      expect(firstCompletion['q1'], 'show');
      expect(firstCompletion['q2'], 'dependent');
      final completionCountBeforeEdit = snapshots
          .where((s) => s != null)
          .length;

      // Edit Q1 to value that hides Q2 branch.
      await tester.enterText(find.byType(TextFormField).first, 'hide');
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 350));
      await tester.pumpAndSettle();

      // Null callback(s) emitted: questionnaire became pending.
      expect(snapshots.where((s) => s == null).length, greaterThanOrEqualTo(1));
      // No new completion yet.
      expect(
        snapshots.where((s) => s != null).length,
        completionCountBeforeEdit,
      );

      // Q2 removed from visible UI.
      expect(find.text('dependent'), findsNothing);
      // Q1 still visible.
      expect(find.byType(TextFormField), findsOneWidget);
      // Submit becomes visible because Q1 is now last (Q2 removed).
      expect(find.text('Submit'), findsOneWidget);

      // Now tap Submit: new branch applies.
      await tester.tap(find.text('Submit'));
      await tester.pumpAndSettle();

      // Q2 hidden (condition evaluates 'hide' != 'show'), so completion has only q1.
      final finalCompletion = snapshots.where((s) => s != null).last!;
      expect(finalCompletion['q1'], 'hide');
      expect(finalCompletion.containsKey('q2'), isFalse);
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

      // Non-conditional non-last valid correction syncs via debounce and
      // re-completes with all visible answers.
      final completionsAfterFix = snapshots.where((s) => s != null).toList();
      expect(
        completionsAfterFix.length,
        equals(nonNullCountBeforeInvalid + 1),
        reason:
            'non-conditional valid correction should re-complete via debounce',
      );

      final lastCompletion = completionsAfterFix.last;
      expect(lastCompletion!['q1'], '456');
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

  testWidgets('date question default today auto-completes questionnaire', (
    tester,
  ) async {
    final dateQ = DateQuestion.withId()
      ..id = 'dq'
      ..prompt = 'Pick date'
      ..defaultOption = DefaultDateOption.today;

    final List<Map<String, Object?>?> snapshots = [];

    tester.view.physicalSize = const Size(800, 2000);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      setup(
        QuestionnaireWidget(
          [dateQ],
          onComplete: (state) {
            snapshots.add(_snapshot(state));
          },
        ),
      ),
    );
    await tester.pumpAndSettle();

    final completion = snapshots.where((s) => s != null).last;
    expect(completion!['dq'], isA<DateTime>());
  });

  testWidgets('clearing a date answer invalidates questionnaire completion', (
    tester,
  ) async {
    final questionnaireKey = GlobalKey<QuestionnaireWidgetState>();
    final dateQ = DateQuestion.withId()
      ..id = 'dq'
      ..prompt = 'Pick date';

    final List<Map<String, Object?>?> snapshots = [];

    tester.view.physicalSize = const Size(800, 2000);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      setup(
        QuestionnaireWidget(
          [dateQ],
          key: questionnaireKey,
          onComplete: (state) {
            snapshots.add(_snapshot(state));
          },
        ),
      ),
    );
    await tester.pumpAndSettle();

    final dateWidget = tester.widget<DateQuestionWidget>(
      find.byType(DateQuestionWidget),
    );
    dateWidget.onDone!(dateQ.constructAnswer(DateTime(2025, 6)));
    await tester.pumpAndSettle();

    final beforeClear = snapshots.where((s) => s != null).length;

    final updatedDateWidget = tester.widget<DateQuestionWidget>(
      find.byType(DateQuestionWidget),
    );
    updatedDateWidget.onCleared!();
    await tester.pumpAndSettle();

    expect(snapshots.last, isNull);
    expect(snapshots.where((s) => s != null).length, beforeClear);
    expect(
      questionnaireKey.currentState!.validateSyncAndBuildPayload(),
      isNull,
    );
  });

  testWidgets(
    'conditional date question restores previous answer when re-shown',
    (tester) async {
      final q1 = _boolQuestion('q1', 'Show date picker?');
      final dateQ = DateQuestion.withId()
        ..id = 'dq'
        ..prompt = 'Pick date'
        ..conditional = QuestionConditional.withCondition(
          CompositeExpression(
            logicType: LogicType.and,
            expressions: [BooleanExpression()..target = 'q1'],
          ),
        );

      tester.view.physicalSize = const Size(800, 2000);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(setup(QuestionnaireWidget([q1, dateQ])));
      await tester.pumpAndSettle();

      await tester.tap(find.text('yes'));
      await tester.pumpAndSettle();
      await tester.pump(const Duration(milliseconds: 500));
      await tester.pumpAndSettle();

      final dateWidget = tester.widget<DateQuestionWidget>(
        find.byType(DateQuestionWidget),
      );
      dateWidget.onDone!(dateQ.constructAnswer(DateTime(2025, 6, 15)));
      await tester.pumpAndSettle();

      await tester.tap(find.text('no').first);
      await tester.pumpAndSettle();
      expect(find.byType(DateQuestionWidget), findsNothing);

      await tester.tap(find.text('yes'));
      await tester.pumpAndSettle();
      await tester.pump(const Duration(milliseconds: 500));
      await tester.pumpAndSettle();

      expect(find.byType(DateQuestionWidget), findsOneWidget);
      expect(find.textContaining('2025-06-15'), findsOneWidget);
    },
  );
}
