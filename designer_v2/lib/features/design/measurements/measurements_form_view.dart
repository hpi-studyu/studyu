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

        final surveys = formViewModel.measurementViewModels
            .whereType<MeasurementSurveyFormViewModel>()
            .toList();

        final nutritionTasks = formViewModel.measurementViewModels
            .whereType<NutritionFormViewModel>()
            .toList();

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
                  final bool isEnabled = formViewModel.isNutritionEnabled;

                  // M3 SEMANTIC COLORS
                  // Enabled: High emphasis (Surface color, usually White/Dark Grey)
                  // Disabled: Medium emphasis (Surface Variant, usually Light Grey/Grey)
                  final backgroundColor = isEnabled
                      ? colorScheme.surface
                      : colorScheme.surfaceContainerHighest;

                  return Column(
                    children: [
                      const SizedBox(height: 16.0),
                      if (formViewModel.canAddMeasurement || isEnabled)
                        Card(
                          // M3: Elevated Card (Enabled) vs Filled Card (Disabled)
                          elevation: isEnabled ? 2.0 : 0.0,
                          color: backgroundColor,
                          // M3: Standard Corner Radius is 12.0 for cards
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12.0),
                          ),
                          // Clip is required so InkWell ripple doesn't overflow corners
                          clipBehavior: Clip.antiAlias,
                          child: InkWell(
                            // LOGIC: Tap to edit ONLY if enabled and task exists
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
                                  // LEADING ICON (Visual Anchor)
                                  // Colored Primary when active to draw attention
                                  Icon(
                                    Icons.restaurant_menu_rounded,
                                    color: isEnabled
                                        ? colorScheme.primary
                                        : colorScheme.onSurfaceVariant,
                                  ),
                                  const SizedBox(width: 16.0),

                                  // TEXT CONTENT
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
                                                fontWeight: FontWeight
                                                    .w500, // Medium weight
                                              ),
                                        ),
                                        // SUBTITLE
                                        // Show instruction if disabled, or context if enabled
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

                                  // NAVIGATION AFFORDANCE (The Chevron)
                                  // Indicates to the user that this row is clickable
                                  if (isEnabled) ...[
                                    Icon(
                                      Icons.chevron_right_rounded,
                                      color: colorScheme.onSurfaceVariant
                                          .withOpacity(0.5),
                                    ),
                                    const SizedBox(width: 8),
                                  ],

                                  // THE SWITCH
                                  // Handles the state toggling independently of navigation
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

                      // VISUAL SEPARATION
                      // Only show divider if there are surveys below
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
                        hideLeadingTrailingWhenEmpty: false,
                        reorderable: false,
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
