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
              label: tr.form_field_nutrition_instructions,
              input: ReactiveTextField(
                formControl: widget.formViewModel.instructionsControl,
                decoration: InputDecoration(
                  hintText: tr.form_field_nutrition_instructions_hint,
                ),
                keyboardType: TextInputType.multiline,
                minLines: 3,
                maxLines: 5,
              ),
            ),
            FormTableRow(
              control: widget.formViewModel.collectMealContextControl,
              label: tr.form_field_nutrition_collect_meal_context,
              input: ReactiveSwitch(
                formControl: widget.formViewModel.collectMealContextControl,
              ),
            ),
            FormTableRow(
              control: widget.formViewModel.allowRecipesControl,
              label: tr.form_field_nutrition_allow_recipes,
              input: ReactiveSwitch(
                formControl: widget.formViewModel.allowRecipesControl,
              ),
            ),
            FormTableRow(
              control: widget.formViewModel.minimumMealsRequiredControl,
              label: tr.form_field_nutrition_minimum_meals_required,
              input: ReactiveTextField(
                formControl: widget.formViewModel.minimumMealsRequiredControl,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                decoration: InputDecoration(
                  hintText: tr.form_field_nutrition_minimum_meals_hint,
                ),
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
