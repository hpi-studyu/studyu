import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:reactive_forms/reactive_forms.dart';
import 'package:studyu_core/core.dart';
import 'package:studyu_designer_v2/common_views/async_value_widget.dart';
import 'package:studyu_designer_v2/common_views/text_paragraph.dart';
import 'package:studyu_designer_v2/features/design/measurements/nutrition/nutrition_form_controller.dart';
import 'package:studyu_designer_v2/features/design/measurements/survey/survey_form_controller.dart';
import 'package:studyu_designer_v2/features/design/shared/schedule/schedule_form_data.dart';
import 'package:studyu_designer_v2/features/design/study_design_page_view.dart';
import 'package:studyu_designer_v2/features/design/study_form_providers.dart';
import 'package:studyu_designer_v2/features/forms/form_list_view.dart';
import 'package:studyu_designer_v2/features/forms/form_view_model_collection.dart';
import 'package:studyu_designer_v2/features/study/study_controller.dart';
import 'package:studyu_designer_v2/localization/app_translation.dart';

class StudyDesignMeasurementsFormView extends StudyDesignPageWidget {
  const StudyDesignMeasurementsFormView(super.studyId, {super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(studyControllerProvider(studyId));

    // MATERIAL 3 THEME ACCESS
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return AsyncValueWidget<Study>(
      value: state.study,
      data: (study) {
        final formViewModel = ref.watch(
          measurementsFormViewModelProvider(studyId),
        );

        return ReactiveForm(
          formGroup: formViewModel.form,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              TextParagraph(
                text: tr.form_study_design_measurements_description,
              ),
              const SizedBox(height: 32.0),
              ReactiveFormConsumer(
                builder: (context, form, child) {
                  // Compute surveys inside ReactiveFormConsumer so it updates on form changes
                  final surveys = formViewModel.measurementViewModels
                      .whereType<MeasurementSurveyFormViewModel>()
                      .toList();

                  final nutritionTasks = formViewModel.measurementViewModels
                      .whereType<NutritionFormViewModel>()
                      .toList();
                  final bool isEnabled = formViewModel.isNutritionEnabled;

                  final backgroundColor = isEnabled
                      ? colorScheme.surface
                      : colorScheme.surfaceContainerHighest;

                  return Column(
                    children: [
                      const SizedBox(height: 16.0),
                      if (formViewModel.canAddMeasurement || isEnabled)
                        Card(
                          elevation: isEnabled ? 2.0 : 0.0,
                          color: backgroundColor,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12.0),
                          ),
                          clipBehavior: Clip.antiAlias,
                          child: InkWell(
                            onTap: (isEnabled && nutritionTasks.isNotEmpty)
                                ? () => formViewModel.onSelectItem(
                                    nutritionTasks.first,
                                  )
                                : null,
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16.0,
                                vertical: 12.0,
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.restaurant_menu_rounded,
                                    color: isEnabled
                                        ? colorScheme.primary
                                        : colorScheme.onSurfaceVariant,
                                  ),
                                  const SizedBox(width: 16.0),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          tr.form_nutrition_tracking_title,
                                          style: theme.textTheme.bodyLarge
                                              ?.copyWith(
                                                color: colorScheme.onSurface,
                                                fontWeight: FontWeight.w500,
                                              ),
                                        ),
                                        if (!isEnabled) ...[
                                          const SizedBox(height: 4),
                                          Text(
                                            tr.form_nutrition_tracking_enable_hint,
                                            style: theme.textTheme.bodyMedium
                                                ?.copyWith(
                                                  color: colorScheme
                                                      .onSurfaceVariant,
                                                ),
                                          ),
                                        ],
                                      ],
                                    ),
                                  ),
                                  if (isEnabled) ...[
                                    Icon(
                                      Icons.chevron_right_rounded,
                                      color: colorScheme.onSurfaceVariant
                                          .withOpacity(0.5),
                                    ),
                                    const SizedBox(width: 8),
                                  ],
                                  Switch(
                                    value: isEnabled,
                                    onChanged: formViewModel.canAddMeasurement
                                        ? (value) =>
                                              formViewModel.isNutritionEnabled =
                                                  value
                                        : null,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),

                      const SizedBox(height: 16.0),

                      // FFQ (Food Frequency Questionnaire) Card
                      if (formViewModel.canAddMeasurement)
                        Card(
                          elevation: formViewModel.isFFQEnabled ? 2.0 : 0.0,
                          color: formViewModel.isFFQEnabled
                              ? colorScheme.surface
                              : colorScheme.surfaceContainerHighest,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12.0),
                          ),
                          clipBehavior: Clip.antiAlias,
                          child: InkWell(
                            onTap: formViewModel.isFFQEnabled
                                ? null
                                : formViewModel.onNewFFQ,
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16.0,
                                vertical: 12.0,
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.list_alt_rounded,
                                    color: formViewModel.isFFQEnabled
                                        ? colorScheme.primary
                                        : colorScheme.onSurfaceVariant,
                                  ),
                                  const SizedBox(width: 16.0),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Food Frequency Questionnaire (FFQ)',
                                          style: theme.textTheme.bodyLarge
                                              ?.copyWith(
                                                color: colorScheme.onSurface,
                                                fontWeight: FontWeight.w500,
                                              ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          formViewModel.isFFQEnabled
                                              ? 'FFQ added - edit below'
                                              : 'Add standardized dietary assessment questionnaire',
                                          style: theme.textTheme.bodyMedium
                                              ?.copyWith(
                                                color: colorScheme
                                                    .onSurfaceVariant,
                                              ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  if (!formViewModel.isFFQEnabled)
                                    Icon(
                                      Icons.add_circle_outline_rounded,
                                      color: colorScheme.primary,
                                    ),
                                  if (formViewModel.isFFQEnabled)
                                    Icon(
                                      Icons.check_circle_rounded,
                                      color: colorScheme.primary,
                                    ),
                                ],
                              ),
                            ),
                          ),
                        ),

                      // Individual 14-day FFQ survey cards
                      if (formViewModel.canAddMeasurement)
                        for (int i = 0; i < FFQQuestions.ffqDaySurveyTitles.length; i++) ...[
                          const SizedBox(height: 8.0),
                          Builder(
                            builder: (context) {
                              final dayIndex = i;
                              final dayTitle = FFQQuestions.ffqDaySurveyTitles[dayIndex];
                              final dayAdded = formViewModel.isFFQDaySurveyAdded(dayIndex);
                              return Card(
                                elevation: dayAdded ? 2.0 : 0.0,
                                color: dayAdded
                                    ? colorScheme.surface
                                    : colorScheme.surfaceContainerHighest,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12.0),
                                ),
                                clipBehavior: Clip.antiAlias,
                                child: InkWell(
                                  onTap: dayAdded
                                      ? null
                                      : () => formViewModel.onNewFFQForDay(dayIndex),
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 16.0,
                                      vertical: 12.0,
                                    ),
                                    child: Row(
                                      children: [
                                        Icon(
                                          Icons.calendar_view_week_rounded,
                                          color: dayAdded
                                              ? colorScheme.primary
                                              : colorScheme.onSurfaceVariant,
                                        ),
                                        const SizedBox(width: 16.0),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                dayTitle,
                                                style: theme.textTheme.bodyLarge
                                                    ?.copyWith(
                                                      color: colorScheme.onSurface,
                                                      fontWeight: FontWeight.w500,
                                                    ),
                                              ),
                                              const SizedBox(height: 4),
                                              Text(
                                                dayAdded
                                                    ? 'Added - edit below'
                                                    : 'Add this survey',
                                                style: theme.textTheme.bodyMedium
                                                    ?.copyWith(
                                                      color: colorScheme
                                                          .onSurfaceVariant,
                                                    ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        if (!dayAdded)
                                          Icon(
                                            Icons.add_circle_outline_rounded,
                                            color: colorScheme.primary,
                                          ),
                                        if (dayAdded)
                                          Icon(
                                            Icons.check_circle_rounded,
                                            color: colorScheme.primary,
                                          ),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ],

                      const SizedBox(height: 16.0),

                      // VISUAL SEPARATION
                      if (surveys.isNotEmpty) ...[
                        Divider(
                          color: colorScheme.outlineVariant,
                          thickness: 1,
                        ),
                        const SizedBox(height: 16.0),
                      ],

                      FormListView<ManagedFormViewModel<IFormDataWithSchedule>>(
                        control: formViewModel.measurementsArray,
                        items: surveys,
                        onSelectItem: formViewModel.onSelectItem,
                        getActionsAt: (viewModel, _) =>
                            formViewModel.availablePopupActions(viewModel),
                        onNewItem: formViewModel.canAddMeasurement
                            ? formViewModel.onNewSurvey
                            : null,
                        onNewItemLabel: tr.form_array_measurements_surveys_new,
                        rowTitle: (viewModel) =>
                            ((viewModel.formData as dynamic).title
                                as String?) ??
                            '',
                        sectionTitle: tr.form_array_measurements_surveys,
                      ),
                    ],
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }
}
