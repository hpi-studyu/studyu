import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:studyu_app/l10n/app_localizations.dart';
import 'package:studyu_app/widgets/questionnaire/questions/medication_question_widget.dart';
import 'package:studyu_core/core.dart';

MedicationProductSnapshot snapshot() => const MedicationProductSnapshot(
  pzn: '03752864',
  officialName: 'Ibuprofen Test',
  activeIngredientCount: 1,
  dosageForm: MedicationDosageForm(patientFriendlyShort: 'Tablet'),
  components: [],
  source: MedicationSource(name: 'BfArM', releaseDate: '2026-09-15'),
);

Widget setup(Widget child) => MaterialApp(
  localizationsDelegates: AppLocalizations.localizationsDelegates,
  supportedLocales: AppLocalizations.supportedLocales,
  locale: const Locale('en'),
  home: Scaffold(body: child),
);

void main() {
  testWidgets('looks up a PZN, accepts quantity, and submits a typed answer', (
    tester,
  ) async {
    final question = MedicationQuestion.withId();
    Answer<MedicationAnswer>? submitted;

    await tester.pumpWidget(
      setup(
        MedicationQuestionWidget(
          question: question,
          debounceDuration: Duration.zero,
          exactLookup: (pzn) async {
            expect(pzn, '03752864');
            return snapshot();
          },
          nameSearch: (_) async => [],
          onDone: (answer) => submitted = answer,
        ),
      ),
    );

    await tester.enterText(find.byType(TextField).first, '03752864');
    await tester.pump();
    await tester.pump();

    expect(find.text('Ibuprofen Test'), findsOneWidget);
    await tester.tap(find.text('Ibuprofen Test'));
    await tester.pump();
    await tester.enterText(
      find.byKey(const ValueKey('medication_quantity')),
      '0,5',
    );
    await tester.pump();
    await tester.tap(find.text('Use this medication'));
    await tester.pump();

    expect(submitted, isNotNull);
    expect(submitted!.response.medication.pzn, '03752864');
    expect(submitted!.response.quantity, 0.5);
  });
}
