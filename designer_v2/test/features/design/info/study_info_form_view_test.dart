import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:reactive_forms/reactive_forms.dart';
import 'package:studyu_designer_v2/common_views/character_count_text_field.dart';

void main() {
  testWidgets('character counter only appears while field is focused', (
    tester,
  ) async {
    final control = FormControl<String>(value: 'hello');

    await tester.pumpWidget(
      MaterialApp(
        home: Material(
          child: ReactiveForm(
            formGroup: FormGroup({'field': control}),
            child: Column(
              children: [
                CharacterCountTextField(
                  formControl: control,
                  hintText: 'Field',
                  maxLength: 10,
                ),
                const TextField(),
              ],
            ),
          ),
        ),
      ),
    );

    expect(find.text('5/10'), findsNothing);

    await tester.tap(find.byType(TextField).first);
    await tester.pumpAndSettle();

    expect(find.text('5/10'), findsOneWidget);

    await tester.enterText(find.byType(TextField).first, '1234567890123');
    await tester.pumpAndSettle();

    expect(control.value, '1234567890');
    expect(find.text('10/10'), findsOneWidget);

    tester.binding.focusManager.primaryFocus?.unfocus();
    await tester.pumpAndSettle();

    expect(find.text('10/10'), findsNothing);
  });

  test('phone field uses plain text implementation', () {
    final source = File(
      'lib/features/design/info/study_info_form_view.dart',
    ).readAsStringSync();

    expect(source, contains('hintText: tr.form_field_contact_phone'));
    expect(source, contains('input: CharacterCountTextField('));
    expect(source, isNot(contains('PhoneFormField')));
    expect(source, isNot(contains('_SplitPhoneField')));
  });
}
