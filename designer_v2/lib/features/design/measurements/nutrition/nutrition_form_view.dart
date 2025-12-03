import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:reactive_forms/reactive_forms.dart';
import 'package:studyu_designer_v2/common_views/form_table_layout.dart';
import 'package:studyu_designer_v2/features/design/measurements/nutrition/nutrition_form_controller.dart';
import 'package:studyu_designer_v2/features/design/shared/schedule/schedule_controls_view.dart';
import 'package:studyu_designer_v2/features/forms/form_validation.dart';
import 'package:studyu_designer_v2/localization/app_translation.dart';

class NutritionFormView extends ConsumerStatefulWidget {
  const NutritionFormView({required this.formViewModel, super.key});

  final NutritionFormViewModel formViewModel;

  @override
  ConsumerState<NutritionFormView> createState() => _NutritionFormViewState();
}

class _NutritionFormViewState extends ConsumerState<NutritionFormView> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        FormTableLayout(
          rows: [
            FormTableRow(
              control: widget.formViewModel.titleControl,
              label: tr
                  .form_field_measurement_survey_title, // Reusing survey title label
              input: ReactiveTextField(
                formControl: widget.formViewModel.titleControl,
                decoration: InputDecoration(
                  hintText: tr.form_field_measurement_survey_title,
                ),
                inputFormatters: [LengthLimitingTextInputFormatter(200)],
                validationMessages:
                    widget.formViewModel.titleControl.validationMessages,
              ),
            ),
            FormTableRow(
              control: widget.formViewModel.instructionsControl,
              label: "Instructions", // TODO: Add translation
              input: ReactiveTextField(
                formControl: widget.formViewModel.instructionsControl,
                decoration: const InputDecoration(
                  hintText: "Enter instructions for the participant",
                ),
                keyboardType: TextInputType.multiline,
                minLines: 3,
                maxLines: 5,
              ),
            ),
            FormTableRow(
              control: widget.formViewModel.collectMealContextControl,
              label: "Collect Meal Context", // TODO: Add translation
              input: ReactiveSwitch(
                formControl: widget.formViewModel.collectMealContextControl,
              ),
            ),
            FormTableRow(
              control: widget.formViewModel.allowRecipesControl,
              label: "Allow Recipes", // TODO: Add translation
              input: ReactiveSwitch(
                formControl: widget.formViewModel.allowRecipesControl,
              ),
            ),
            FormTableRow(
              control: widget.formViewModel.minimumMealsRequiredControl,
              label: "Minimum Meals Required", // TODO: Add translation
              input: ReactiveTextField(
                formControl: widget.formViewModel.minimumMealsRequiredControl,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                decoration: const InputDecoration(hintText: "Optional"),
              ),
            ),
          ],
        ),
        const SizedBox(height: 28.0),
        ScheduleControls(formViewModel: widget.formViewModel),
      ],
    );
  }
}
