import 'package:flutter/material.dart';
import 'package:studyu_designer_v2/localization/app_translation.dart';

enum MeasurementSelection { blankSurvey, template, nutrition }

class MeasurementSelectionDialog extends StatelessWidget {
  const MeasurementSelectionDialog({required this.canAddNutrition, super.key});

  final bool canAddNutrition;

  @override
  Widget build(BuildContext context) {
    return SimpleDialog(
      title: Text(tr.form_measurement_type_select),
      children: [
        _MeasurementOption(
          selection: MeasurementSelection.blankSurvey,
          icon: Icons.assignment_outlined,
          title: tr.form_measurement_type_survey,
          description: tr.form_measurement_type_survey_description,
        ),
        _MeasurementOption(
          selection: MeasurementSelection.template,
          icon: Icons.library_add_rounded,
          title: tr.form_measurement_type_template,
          description: tr.form_measurement_type_template_description,
        ),
        if (canAddNutrition)
          _MeasurementOption(
            selection: MeasurementSelection.nutrition,
            icon: Icons.restaurant_outlined,
            title: tr.form_measurement_type_nutrition,
            description: tr.form_measurement_type_nutrition_description,
          ),
      ],
    );
  }
}

class _MeasurementOption extends StatelessWidget {
  const _MeasurementOption({
    required this.selection,
    required this.icon,
    required this.title,
    required this.description,
  });

  final MeasurementSelection selection;
  final IconData icon;
  final String title;
  final String description;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      subtitle: Text(description),
      contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 4),
      onTap: () => Navigator.of(context).pop(selection),
    );
  }
}
