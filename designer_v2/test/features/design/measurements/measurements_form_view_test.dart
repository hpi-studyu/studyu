@TestOn('browser')
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mockito/mockito.dart';
import 'package:studyu_core/core.dart';
import 'package:studyu_designer_v2/constants.dart';
import 'package:studyu_designer_v2/features/design/measurements/measurements_form_controller.dart';
import 'package:studyu_designer_v2/features/design/measurements/measurements_form_data.dart';
import 'package:studyu_designer_v2/features/design/measurements/measurements_form_view.dart';
import 'package:studyu_designer_v2/features/design/measurements/nutrition/nutrition_form_controller.dart';
import 'package:studyu_designer_v2/features/design/measurements/nutrition/nutrition_form_data.dart';
import 'package:studyu_designer_v2/features/design/measurements/survey/survey_form_controller.dart';
import 'package:studyu_designer_v2/features/design/measurements/survey/survey_form_data.dart';
import 'package:studyu_designer_v2/features/design/shared/questionnaire/questionnaire_form_data.dart';
import 'package:studyu_designer_v2/features/design/study_form_providers.dart';
import 'package:studyu_designer_v2/features/study/study_controller.dart';
import 'package:studyu_designer_v2/features/study/study_controller_state.dart';
import 'package:studyu_designer_v2/localization/app_localizations_en.dart';
import 'package:studyu_designer_v2/localization/app_translation.dart';
import 'package:studyu_designer_v2/repositories/model_repository.dart';
import 'package:studyu_designer_v2/repositories/study_repository.dart';
import 'package:studyu_designer_v2/routing/router_config.dart';

class _MockStudyRepository extends Mock implements IStudyRepository {}

void main() {
  setUpAll(() => AppTranslation.setForTesting(AppLocalizationsEn()));

  testWidgets('renders persisted, template, and new measurement titles', (
    tester,
  ) async {
    final study = Study.withId('test-user');
    final router = GoRouter(
      routes: [
        GoRoute(path: '/', builder: (_, _) => const SizedBox.shrink()),
        GoRoute(
          path: '/studies/:studyId/edit/measurements/:measurementId',
          name: studyEditMeasurementRouteName,
          builder: (_, _) => const SizedBox.shrink(),
        ),
      ],
    );
    addTearDown(router.dispose);

    final measurements = MeasurementsFormViewModel(
      study: study,
      router: router,
      formData: MeasurementsFormData(
        measurements: [
          _surveyData('survey-1', 'Persisted survey'),
          _nutritionData('nutrition-1', 'Persisted nutrition'),
        ],
      ),
    );
    final newSurvey =
        measurements.provideWithType(
              MeasurementFormRouteArgs(
                studyId: study.id,
                measurementId: Config.newModelId,
              ),
              null,
            )
            as MeasurementSurveyFormViewModel;
    newSurvey.surveyTitleControl.value = 'Live new survey';
    final newNutrition =
        measurements.provideWithType(
              MeasurementFormRouteArgs(
                studyId: study.id,
                measurementId: Config.newModelId,
              ),
              'nutrition',
            )
            as NutritionFormViewModel;
    newNutrition.titleControl.value = 'Live new nutrition';

    final templateSurvey = measurements.applyTemplate(
      SurveyTemplateRegistry.findById('ffq_26')!,
    )!;
    final templateTitle = templateSurvey.surveyTitleControl.value!;
    expect(measurements.measurementTitle(templateSurvey), templateTitle);
    measurements.measurementViewModelsCollection.commit(templateSurvey);

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
          measurementsFormViewModelProvider(
            study.id,
          ).overrideWithValue(measurements),
        ],
        child: MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: StudyDesignMeasurementsFormView(study.id),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(find.text('Persisted survey'), findsOneWidget);
    expect(find.text('Persisted nutrition'), findsOneWidget);
    expect(find.text(templateTitle), findsOneWidget);
    expect(find.text('Live new survey'), findsOneWidget);
    expect(find.text('Live new nutrition'), findsOneWidget);
  });

  testWidgets('survey selection dismisses the chooser before navigation', (
    tester,
  ) async {
    final study = Study.withId('test-user');
    final router = GoRouter(
      routes: [
        GoRoute(path: '/', builder: (_, _) => const SizedBox.shrink()),
        GoRoute(
          path: '/studies/:studyId/edit/measurements/:measurementId',
          name: studyEditMeasurementRouteName,
          builder: (_, _) => const SizedBox.shrink(),
        ),
      ],
    );
    addTearDown(router.dispose);
    final measurements = MeasurementsFormViewModel(
      study: study,
      router: router,
      formData: MeasurementsFormData(measurements: []),
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
          measurementsFormViewModelProvider(
            study.id,
          ).overrideWithValue(measurements),
        ],
        child: MaterialApp(
          home: Scaffold(body: StudyDesignMeasurementsFormView(study.id)),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Add survey'));
    await tester.pumpAndSettle();
    expect(find.text('Select Measurement Type'), findsOneWidget);

    await tester.tap(find.text('Survey'));
    await tester.pump();

    expect(find.text('Select Measurement Type'), findsNothing);
    expect(
      measurements.measurementViewModelsCollection.retrievableViewModels,
      hasLength(1),
    );
    expect(
      router.routeInformationProvider.value.uri.path,
      contains('/edit/measurements/'),
    );
  });
}

MeasurementSurveyFormData _surveyData(String id, String title) {
  return MeasurementSurveyFormData(
    measurementId: id,
    instanceId: '$id-instance',
    title: title,
    questionnaireFormData: QuestionnaireFormData(questionsData: []),
    isTimeLocked: false,
    hasReminder: false,
  );
}

NutritionFormData _nutritionData(String id, String title) {
  return NutritionFormData(
    measurementId: id,
    instanceId: '$id-instance',
    title: title,
    isTimeLocked: false,
    hasReminder: false,
  );
}
