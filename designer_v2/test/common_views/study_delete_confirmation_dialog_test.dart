import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:studyu_core/core.dart';
import 'package:studyu_designer_v2/common_views/study_delete_confirmation_dialog.dart';
import 'package:studyu_designer_v2/localization/app_localizations_en.dart';
import 'package:studyu_designer_v2/localization/app_translation.dart';

void main() {
  setUpAll(() {
    AppTranslation.setForTesting(AppLocalizationsEn());
  });

  testWidgets('study delete dialog requires acknowledgement and study name', (
    tester,
  ) async {
    final study = Study('study-id', 'owner-id')..title = 'Hypertension Study';

    await tester.pumpWidget(
      MaterialApp(
        home: StudyDeleteConfirmationDialog(
          study: study,
          confirmLabel: 'Delete',
        ),
      ),
    );

    final deleteButtonFinder = find.ancestor(
      of: find.text('Delete'),
      matching: find.byType(ElevatedButton),
    );

    expect(find.text('This permanently deletes study data'), findsOneWidget);
    expect(
      find.byWidgetPredicate(
        (widget) =>
            widget is RichText &&
            widget.text.toPlainText().contains('Current participants'),
      ),
      findsOneWidget,
    );
    expect(
      find.byWidgetPredicate(
        (widget) =>
            widget is RichText &&
            widget.text.toPlainText().contains('Past participants'),
      ),
      findsOneWidget,
    );
    expect(
      find.byKey(const ValueKey('study_delete_read_warning_checkbox')),
      findsOneWidget,
    );
    expect(
      find.byKey(const ValueKey('study_delete_name_confirmation_field')),
      findsOneWidget,
    );
    expect(tester.widget<ElevatedButton>(deleteButtonFinder).onPressed, isNull);

    await tester.ensureVisible(
      find.byKey(const ValueKey('study_delete_read_warning_checkbox')),
    );
    await tester.tap(
      find.byKey(const ValueKey('study_delete_read_warning_checkbox')),
      warnIfMissed: false,
    );
    await tester.pump();
    expect(tester.widget<ElevatedButton>(deleteButtonFinder).onPressed, isNull);

    await tester.ensureVisible(
      find.byKey(const ValueKey('study_delete_name_confirmation_field')),
    );
    await tester.enterText(
      find.byKey(const ValueKey('study_delete_name_confirmation_field')),
      'Wrong Study',
    );
    await tester.pump();
    expect(tester.widget<ElevatedButton>(deleteButtonFinder).onPressed, isNull);

    await tester.enterText(
      find.byKey(const ValueKey('study_delete_name_confirmation_field')),
      'Hypertension Study',
    );
    await tester.pump();
    expect(
      tester.widget<ElevatedButton>(deleteButtonFinder).onPressed,
      isNotNull,
    );
  });
}
