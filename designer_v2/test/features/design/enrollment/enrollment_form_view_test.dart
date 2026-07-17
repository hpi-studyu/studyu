@TestOn('browser')
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mockito/mockito.dart';
import 'package:studyu_core/core.dart';
import 'package:studyu_designer_v2/features/design/enrollment/enrollment_form_controller.dart';
import 'package:studyu_designer_v2/features/design/enrollment/enrollment_form_view.dart';
import 'package:studyu_designer_v2/features/design/study_form_providers.dart';
import 'package:studyu_designer_v2/features/study/study_controller.dart';
import 'package:studyu_designer_v2/features/study/study_controller_state.dart';
import 'package:studyu_designer_v2/localization/app_localizations_en.dart';
import 'package:studyu_designer_v2/localization/app_translation.dart';
import 'package:studyu_designer_v2/repositories/model_repository.dart';
import 'package:studyu_designer_v2/repositories/study_repository.dart';

class _MockStudyRepository extends Mock implements IStudyRepository {}

void main() {
  setUpAll(() => AppTranslation.setForTesting(AppLocalizationsEn()));

  testWidgets(
    'participation subtitles are selectable and tiles remain interactive',
    (tester) async {
      final study = Study.withId('study-1');
      final router = GoRouter(
        routes: [
          GoRoute(path: '/', builder: (_, _) => const SizedBox.shrink()),
        ],
      );
      addTearDown(router.dispose);
      final formViewModel = EnrollmentFormViewModel(
        study: study,
        router: router,
        autosave: false,
      );
      final state = StudyControllerState(
        studyId: study.id,
        studyRepository: _MockStudyRepository(),
        router: router,
        currentUser: null,
        studyWithMetadata: WrappedModel(study),
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            studyControllerProvider(study.id).overrideWithValue(state),
            enrollmentFormViewModelProvider(
              study.id,
            ).overrideWithValue(formViewModel),
          ],
          child: MaterialApp(
            home: Scaffold(
              body: SingleChildScrollView(
                child: StudyDesignEnrollmentFormView(study.id),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      final tiles = find.byType(RadioListTile<Participation>);
      final options = formViewModel.enrollmentTypeControlOptions;
      final localization = AppLocalizationsEn();
      final descriptions = [
        localization.form_field_enrollment_type_open_description,
        localization.form_field_enrollment_type_invite_description,
      ];
      final sectionDescriptions = [
        localization.form_array_screener_questions_description,
        localization.form_array_consent_items_description,
      ];
      for (final description in sectionDescriptions) {
        expect(
          find.byWidgetPredicate(
            (widget) => widget is SelectableText && widget.data == description,
          ),
          findsOneWidget,
        );
      }
      expect(tiles, findsNWidgets(options.length));

      for (var index = 0; index < options.length; index++) {
        final tile = tiles.at(index);
        final subtitle = find.descendant(
          of: tile,
          matching: find.byType(SelectableText),
        );
        expect(subtitle, findsOneWidget);
        expect(
          tester.widget<SelectableText>(subtitle).data,
          descriptions[index],
        );

        final radio = find.descendant(
          of: tile,
          matching: find.byType(Radio<Participation>),
        );
        expect(radio, findsOneWidget);
        await tester.tap(radio);
        await tester.pump();
        expect(formViewModel.enrollmentTypeControl.value, options[index].value);
      }
    },
  );
}
