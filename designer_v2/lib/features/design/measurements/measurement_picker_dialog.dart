import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:studyu_core/core.dart';
import 'package:studyu_designer_v2/common_views/dialog.dart';
import 'package:studyu_designer_v2/common_views/form_buttons.dart';
import 'package:studyu_designer_v2/common_views/primary_button.dart';
import 'package:studyu_designer_v2/common_views/secondary_button.dart';
import 'package:studyu_designer_v2/features/design/measurements/measurements_form_controller.dart';
import 'package:studyu_designer_v2/features/design/measurements/survey_template_providers.dart';
import 'package:studyu_designer_v2/localization/app_translation.dart';

enum MeasurementSelection { blankSurvey }

enum _MeasurementCategory { all, nutrition }

extension on _MeasurementCategory {
  String get label => switch (this) {
    _MeasurementCategory.all => tr.form_measurement_category_all,
    _MeasurementCategory.nutrition => tr.form_measurement_category_nutrition,
  };

  String get heading => switch (this) {
    _MeasurementCategory.all => tr.form_measurement_category_all_heading,
    _MeasurementCategory.nutrition =>
      tr.form_measurement_category_nutrition_heading,
  };

  IconData get icon => switch (this) {
    _MeasurementCategory.all => Icons.grid_view_rounded,
    _MeasurementCategory.nutrition => Icons.restaurant_outlined,
  };

  bool includes(SurveyTemplate template) =>
      this == _MeasurementCategory.all || template.tags.contains(name);

  bool get includesNutrition =>
      this == _MeasurementCategory.all ||
      this == _MeasurementCategory.nutrition;

  int measurementCount(Iterable<SurveyTemplate> templates) =>
      templates.where(includes).length + (includesNutrition ? 1 : 0);
}

/// Lets researchers create a custom survey or browse predefined measurements.
class MeasurementPickerDialog extends ConsumerStatefulWidget {
  const MeasurementPickerDialog({
    required this.formViewModel,
    required this.canAddNutrition,
    super.key,
  });

  final MeasurementsFormViewModel formViewModel;
  final bool canAddNutrition;

  @override
  ConsumerState<MeasurementPickerDialog> createState() =>
      _MeasurementPickerDialogState();
}

class _MeasurementPickerDialogState
    extends ConsumerState<MeasurementPickerDialog> {
  late final Future<List<SurveyTemplate>> _templates;
  _MeasurementCategory _category = _MeasurementCategory.all;
  bool _nutritionSelected = false;
  bool _isSubmitting = false;
  final Set<SurveyTemplate> _selectedTemplates = {};
  final Set<SurveyTemplateDayEntry> _selectedDayEntries = {};

  int get _selectionCount =>
      (_nutritionSelected ? 1 : 0) +
      _selectedTemplates.length +
      _selectedDayEntries.length;

  bool get _hasSelection => _selectionCount > 0;

  @override
  void initState() {
    super.initState();
    _templates = ref.read(surveyTemplateRepositoryProvider).getTemplates();
  }

  @override
  Widget build(BuildContext context) {
    final viewport = MediaQuery.sizeOf(context);
    final width = math.min(860.0, viewport.width - 48.0);

    return FutureBuilder<List<SurveyTemplate>>(
      future: _templates,
      builder: (context, snapshot) {
        final waiting = snapshot.connectionState == ConnectionState.waiting;
        final templates = snapshot.data ?? [];
        final preferredHeight = waiting
            ? 360.0
            : math.min(620.0, 250.0 + (templates.length + 1) * 112.0);
        final height = math.min(preferredHeight, viewport.height - 48.0);

        return PopScope(
          canPop: !_isSubmitting,
          child: StandardDialog(
            width: width,
            height: height,
            minWidth: 0,
            minHeight: 0,
            maxWidth: 860,
            maxHeight: 620,
            padding: const EdgeInsets.fromLTRB(32, 28, 32, 16),
            scrollBody: false,
            body: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _PickerHeader(
                  onCreateSurvey: _isSubmitting
                      ? null
                      : () => Navigator.of(
                          context,
                        ).pop(MeasurementSelection.blankSurvey),
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: waiting
                      ? const Center(child: CircularProgressIndicator())
                      : _buildPicker(templates),
                ),
              ],
            ),
            actionButtons: [
              if (_isSubmitting)
                SecondaryButton(text: tr.dialog_cancel, icon: null)
              else
                const DismissButton(),
              PrimaryButton(
                key: const ValueKey('measurement-picker-submit'),
                text: _isSubmitting
                    ? tr.form_survey_template_adding
                    : tr.form_survey_template_add_selected_count(
                        _selectionCount,
                      ),
                icon: null,
                enabled: _hasSelection && !_isSubmitting,
                onPressed: _hasSelection && !_isSubmitting
                    ? _confirmSelection
                    : null,
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildPicker(List<SurveyTemplate> templates) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth >= 640) {
          return _WidePicker(
            category: _category,
            templates: templates,
            canAddNutrition: widget.canAddNutrition,
            formViewModel: widget.formViewModel,
            nutritionSelected: _nutritionSelected,
            selectedTemplates: _selectedTemplates,
            selectedDayEntries: _selectedDayEntries,
            onCategorySelected: _selectCategory,
            onNutritionChanged: _setNutritionSelected,
            onTemplateChanged: _setTemplateSelected,
            onDayEntryChanged: _setDayEntrySelected,
            onDayEntriesChanged: _setDayEntriesSelected,
          );
        }
        return _NarrowPicker(
          category: _category,
          templates: templates,
          canAddNutrition: widget.canAddNutrition,
          formViewModel: widget.formViewModel,
          nutritionSelected: _nutritionSelected,
          selectedTemplates: _selectedTemplates,
          selectedDayEntries: _selectedDayEntries,
          onCategorySelected: _selectCategory,
          onNutritionChanged: _setNutritionSelected,
          onTemplateChanged: _setTemplateSelected,
          onDayEntryChanged: _setDayEntrySelected,
          onDayEntriesChanged: _setDayEntriesSelected,
        );
      },
    );
  }

  void _selectCategory(_MeasurementCategory category) {
    setState(() => _category = category);
  }

  void _setNutritionSelected(bool selected) {
    setState(() => _nutritionSelected = selected);
  }

  void _setTemplateSelected(SurveyTemplate template, bool selected) {
    setState(() {
      if (selected) {
        _selectedTemplates.add(template);
      } else {
        _selectedTemplates.remove(template);
      }
    });
  }

  void _setDayEntrySelected(SurveyTemplateDayEntry entry, bool selected) {
    setState(() {
      if (selected) {
        _selectedDayEntries.add(entry);
      } else {
        _selectedDayEntries.remove(entry);
      }
    });
  }

  void _setDayEntriesSelected(
    Iterable<SurveyTemplateDayEntry> entries,
    bool selected,
  ) {
    setState(() {
      if (selected) {
        _selectedDayEntries.addAll(entries);
      } else {
        _selectedDayEntries.removeAll(entries);
      }
    });
  }

  Future<void> _confirmSelection() async {
    if (!_hasSelection || _isSubmitting) return;
    setState(() => _isSubmitting = true);

    try {
      await widget.formViewModel.addPredefinedMeasurements(
        includeNutrition: _nutritionSelected,
        templates: _selectedTemplates,
        dayEntries: _selectedDayEntries,
      );
      if (mounted) Navigator.of(context).pop();
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }
}

class _WidePicker extends StatelessWidget {
  const _WidePicker({
    required this.category,
    required this.templates,
    required this.canAddNutrition,
    required this.formViewModel,
    required this.nutritionSelected,
    required this.selectedTemplates,
    required this.selectedDayEntries,
    required this.onCategorySelected,
    required this.onNutritionChanged,
    required this.onTemplateChanged,
    required this.onDayEntryChanged,
    required this.onDayEntriesChanged,
  });

  final _MeasurementCategory category;
  final List<SurveyTemplate> templates;
  final bool canAddNutrition;
  final MeasurementsFormViewModel formViewModel;
  final bool nutritionSelected;
  final Set<SurveyTemplate> selectedTemplates;
  final Set<SurveyTemplateDayEntry> selectedDayEntries;
  final ValueChanged<_MeasurementCategory> onCategorySelected;
  final ValueChanged<bool> onNutritionChanged;
  final void Function(SurveyTemplate, bool) onTemplateChanged;
  final void Function(SurveyTemplateDayEntry, bool) onDayEntryChanged;
  final void Function(Iterable<SurveyTemplateDayEntry>, bool)
  onDayEntriesChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SizedBox(
          width: 176,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                tr.form_measurement_type_template,
                style: Theme.of(context).textTheme.labelLarge,
              ),
              const SizedBox(height: 8),
              Expanded(
                child: ListView(
                  children: [
                    for (final item in _MeasurementCategory.values)
                      Material(
                        color: Colors.transparent,
                        child: ListTile(
                          selected: category == item,
                          leading: Icon(item.icon),
                          title: Text(item.label),
                          trailing: Text(
                            '${item.measurementCount(templates)}',
                            style: Theme.of(context).textTheme.labelMedium
                                ?.copyWith(
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.onSurfaceVariant,
                                ),
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          onTap: () => onCategorySelected(item),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const VerticalDivider(width: 33),
        Expanded(
          child: _PredefinedMeasurementsList(
            category: category,
            templates: templates,
            canAddNutrition: canAddNutrition,
            formViewModel: formViewModel,
            nutritionSelected: nutritionSelected,
            selectedTemplates: selectedTemplates,
            selectedDayEntries: selectedDayEntries,
            onNutritionChanged: onNutritionChanged,
            onTemplateChanged: onTemplateChanged,
            onDayEntryChanged: onDayEntryChanged,
            onDayEntriesChanged: onDayEntriesChanged,
          ),
        ),
      ],
    );
  }
}

class _NarrowPicker extends StatelessWidget {
  const _NarrowPicker({
    required this.category,
    required this.templates,
    required this.canAddNutrition,
    required this.formViewModel,
    required this.nutritionSelected,
    required this.selectedTemplates,
    required this.selectedDayEntries,
    required this.onCategorySelected,
    required this.onNutritionChanged,
    required this.onTemplateChanged,
    required this.onDayEntryChanged,
    required this.onDayEntriesChanged,
  });

  final _MeasurementCategory category;
  final List<SurveyTemplate> templates;
  final bool canAddNutrition;
  final MeasurementsFormViewModel formViewModel;
  final bool nutritionSelected;
  final Set<SurveyTemplate> selectedTemplates;
  final Set<SurveyTemplateDayEntry> selectedDayEntries;
  final ValueChanged<_MeasurementCategory> onCategorySelected;
  final ValueChanged<bool> onNutritionChanged;
  final void Function(SurveyTemplate, bool) onTemplateChanged;
  final void Function(SurveyTemplateDayEntry, bool) onDayEntryChanged;
  final void Function(Iterable<SurveyTemplateDayEntry>, bool)
  onDayEntriesChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        DropdownButtonFormField<_MeasurementCategory>(
          initialValue: category,
          decoration: InputDecoration(
            labelText: tr.form_measurement_type_template,
          ),
          items: [
            for (final item in _MeasurementCategory.values)
              DropdownMenuItem(
                value: item,
                child: Row(
                  children: [
                    Icon(item.icon, size: 20),
                    const SizedBox(width: 12),
                    Text(item.label),
                  ],
                ),
              ),
          ],
          onChanged: (value) {
            if (value != null) onCategorySelected(value);
          },
        ),
        const SizedBox(height: 16),
        Expanded(
          child: _PredefinedMeasurementsList(
            category: category,
            templates: templates,
            canAddNutrition: canAddNutrition,
            formViewModel: formViewModel,
            nutritionSelected: nutritionSelected,
            selectedTemplates: selectedTemplates,
            selectedDayEntries: selectedDayEntries,
            onNutritionChanged: onNutritionChanged,
            onTemplateChanged: onTemplateChanged,
            onDayEntryChanged: onDayEntryChanged,
            onDayEntriesChanged: onDayEntriesChanged,
            showHeading: false,
          ),
        ),
      ],
    );
  }
}

class _MeasurementCard extends StatelessWidget {
  const _MeasurementCard({
    required this.child,
    this.onTap,
    this.selected = false,
    this.added = false,
    this.enabled = true,
    this.clipBehavior = Clip.none,
  });

  final Widget child;
  final VoidCallback? onTap;
  final bool selected;
  final bool added;
  final bool enabled;
  final Clip clipBehavior;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final effectiveOnTap = enabled ? onTap : null;
    final content = effectiveOnTap == null
        ? child
        : InkWell(
            borderRadius: BorderRadius.circular(8),
            onTap: effectiveOnTap,
            child: child,
          );

    return Card(
      margin: EdgeInsets.zero,
      color: !enabled || added
          ? colorScheme.surfaceContainerHighest.withValues(alpha: 0.45)
          : selected
          ? colorScheme.primaryContainer.withValues(alpha: 0.2)
          : Colors.white,
      elevation: enabled ? 3 : 0,
      shadowColor: Colors.black.withValues(alpha: 0.15),
      clipBehavior: clipBehavior,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: selected && enabled
            ? BorderSide(
                color: colorScheme.primary.withValues(alpha: 0.5),
                width: 1.5,
              )
            : BorderSide(
                color: colorScheme.outlineVariant.withValues(alpha: 0.45),
              ),
      ),
      child: content,
    );
  }
}

class _AddedBadge extends StatelessWidget {
  const _AddedBadge({this.text});

  final String? text;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        child: Text(
          text ?? tr.form_survey_template_added,
          style: theme.textTheme.labelSmall?.copyWith(
            color: colorScheme.onPrimaryContainer,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}

class _MetadataBadge extends StatelessWidget {
  const _MetadataBadge({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.55),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
        child: Text(
          text,
          style: theme.textTheme.labelSmall?.copyWith(
            color: colorScheme.onSurfaceVariant,
          ),
        ),
      ),
    );
  }
}

class _PickerHeader extends StatelessWidget {
  const _PickerHeader({required this.onCreateSurvey});

  final VoidCallback? onCreateSurvey;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      crossAxisAlignment: WrapCrossAlignment.center,
      spacing: 32,
      runSpacing: 4,
      children: [
        Text(
          tr.form_measurement_type_select,
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        TextButton(
          key: const ValueKey('measurement-picker-create-survey'),
          onPressed: onCreateSurvey,
          style: TextButton.styleFrom(
            minimumSize: const Size(0, 36),
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            visualDensity: VisualDensity.compact,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.add_rounded, size: 18),
              const SizedBox(width: 4),
              Text(tr.form_measurement_type_survey),
            ],
          ),
        ),
      ],
    );
  }
}

class _PredefinedMeasurementsList extends StatelessWidget {
  const _PredefinedMeasurementsList({
    required this.category,
    required this.templates,
    required this.canAddNutrition,
    required this.formViewModel,
    required this.nutritionSelected,
    required this.selectedTemplates,
    required this.selectedDayEntries,
    required this.onNutritionChanged,
    required this.onTemplateChanged,
    required this.onDayEntryChanged,
    required this.onDayEntriesChanged,
    this.showHeading = true,
  });

  final _MeasurementCategory category;
  final List<SurveyTemplate> templates;
  final bool canAddNutrition;
  final MeasurementsFormViewModel formViewModel;
  final bool nutritionSelected;
  final Set<SurveyTemplate> selectedTemplates;
  final Set<SurveyTemplateDayEntry> selectedDayEntries;
  final ValueChanged<bool> onNutritionChanged;
  final void Function(SurveyTemplate, bool) onTemplateChanged;
  final void Function(SurveyTemplateDayEntry, bool) onDayEntryChanged;
  final void Function(Iterable<SurveyTemplateDayEntry>, bool)
  onDayEntriesChanged;
  final bool showHeading;

  @override
  Widget build(BuildContext context) {
    final visibleTemplates = templates.where(category.includes).toList();
    final showNutrition = category.includesNutrition;
    final itemCount = category.measurementCount(templates);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        LayoutBuilder(
          builder: (context, constraints) {
            final searchWidth = math.min(
              208.0,
              showHeading ? constraints.maxWidth * 0.48 : constraints.maxWidth,
            );

            return Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                if (showHeading) ...[
                  Expanded(
                    child: Text(
                      '${category.heading} · $itemCount',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                ],
                SizedBox(
                  width: searchWidth,
                  child: TextField(
                    enabled: false,
                    decoration: InputDecoration(
                      hintText: tr.form_measurement_search_placeholder,
                      prefixIcon: const Icon(Icons.search_rounded),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
        const SizedBox(height: 12),
        Expanded(
          child: itemCount == 0
              ? Center(child: Text(tr.form_survey_template_empty))
              : ListView.separated(
                  itemCount: itemCount,
                  separatorBuilder: (_, _) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    if (showNutrition && index == 0) {
                      return _NutritionTemplateItem(
                        canAdd: canAddNutrition,
                        selected: nutritionSelected,
                        onChanged: onNutritionChanged,
                      );
                    }
                    final templateIndex = index - (showNutrition ? 1 : 0);
                    final template = visibleTemplates[templateIndex];
                    return _TemplateItem(
                      template: template,
                      formViewModel: formViewModel,
                      selected: selectedTemplates.contains(template),
                      selectedDayEntries: selectedDayEntries,
                      onChanged: onTemplateChanged,
                      onDayEntryChanged: onDayEntryChanged,
                      onDayEntriesChanged: onDayEntriesChanged,
                    );
                  },
                ),
        ),
      ],
    );
  }
}

class _NutritionTemplateItem extends StatelessWidget {
  const _NutritionTemplateItem({
    required this.canAdd,
    required this.selected,
    required this.onChanged,
  });

  final bool canAdd;
  final bool selected;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return _MeasurementCard(
      selected: selected,
      enabled: canAdd,
      onTap: () => onChanged(!selected),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: colorScheme.primaryContainer,
              child: Icon(
                Icons.restaurant_outlined,
                color: colorScheme.onPrimaryContainer,
                size: 20,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    tr.form_measurement_type_nutrition,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(tr.form_measurement_type_nutrition_description),
                ],
              ),
            ),
            const SizedBox(width: 8),
            if (canAdd)
              Checkbox(
                key: const ValueKey('measurement-picker-nutrition'),
                value: selected,
                onChanged: (value) => onChanged(value ?? false),
              )
            else
              _AddedBadge(text: tr.form_survey_template_added_to_study),
          ],
        ),
      ),
    );
  }
}

class _TemplateItem extends StatefulWidget {
  const _TemplateItem({
    required this.template,
    required this.formViewModel,
    required this.selected,
    required this.selectedDayEntries,
    required this.onChanged,
    required this.onDayEntryChanged,
    required this.onDayEntriesChanged,
  });

  final SurveyTemplate template;
  final MeasurementsFormViewModel formViewModel;
  final bool selected;
  final Set<SurveyTemplateDayEntry> selectedDayEntries;
  final void Function(SurveyTemplate, bool) onChanged;
  final void Function(SurveyTemplateDayEntry, bool) onDayEntryChanged;
  final void Function(Iterable<SurveyTemplateDayEntry>, bool)
  onDayEntriesChanged;

  @override
  State<_TemplateItem> createState() => _TemplateItemState();
}

class _TemplateItemState extends State<_TemplateItem> {
  bool _expanded = false;

  bool get _isAlreadyAdded =>
      widget.formViewModel.isSurveyWithTitleAdded(widget.template.title);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final template = widget.template;
    final dayEntries = template.dayEntries ?? const <SurveyTemplateDayEntry>[];
    final availableDayEntries = dayEntries
        .where(
          (entry) => !widget.formViewModel.isSurveyWithTitleAdded(entry.title),
        )
        .toList();
    final selectedDayEntries = availableDayEntries
        .where(widget.selectedDayEntries.contains)
        .toList();
    final allAvailableDaysSelected =
        availableDayEntries.isNotEmpty &&
        selectedDayEntries.length == availableDayEntries.length;
    final addedDayCount = dayEntries.length - availableDayEntries.length;
    final anyDaySelected = selectedDayEntries.isNotEmpty;
    final checkedDayCount = addedDayCount + selectedDayEntries.length;
    final allDaysChecked =
        dayEntries.isNotEmpty && checkedDayCount == dayEntries.length;
    final anyDaysChecked = checkedDayCount > 0;
    final cardSelected = template.isMultiDay ? anyDaySelected : widget.selected;
    final enabled = template.isMultiDay
        ? availableDayEntries.isNotEmpty
        : !_isAlreadyAdded;

    final header = Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: colorScheme.primaryContainer,
            child: Icon(
              template.isMultiDay
                  ? Icons.calendar_view_week_rounded
                  : Icons.assignment_outlined,
              color: colorScheme.onPrimaryContainer,
              size: 20,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  template.title,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    fontWeight: cardSelected
                        ? FontWeight.w600
                        : FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(template.description),
                const SizedBox(height: 4),
                _MetadataBadge(
                  text: template.isMultiDay
                      ? tr.form_survey_template_multi_day_help(
                          dayEntries.length,
                        )
                      : tr.form_survey_template_single_help,
                ),
              ],
            ),
          ),
          if (!enabled) ...[
            const SizedBox(width: 8),
            _AddedBadge(text: tr.form_survey_template_added_to_study),
          ],
          if (!template.isMultiDay && enabled) ...[
            const SizedBox(width: 8),
            Checkbox(
              key: ValueKey('measurement-picker-template-${template.id}'),
              value: cardSelected,
              onChanged: (value) => widget.onChanged(template, value ?? false),
            ),
          ],
          if (template.isMultiDay && enabled) ...[
            const SizedBox(width: 8),
            IconButton(
              key: ValueKey('measurement-picker-expand-${template.id}'),
              tooltip: _expanded
                  ? tr.form_survey_template_collapse_days
                  : tr.form_survey_template_expand_days,
              onPressed: () => setState(() => _expanded = !_expanded),
              icon: Icon(
                _expanded
                    ? Icons.expand_less_rounded
                    : Icons.expand_more_rounded,
              ),
            ),
          ],
        ],
      ),
    );

    return _MeasurementCard(
      selected: cardSelected,
      added: template.isMultiDay && addedDayCount > 0,
      enabled: enabled,
      onTap: template.isMultiDay
          ? null
          : () => widget.onChanged(template, !widget.selected),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          header,
          if (template.isMultiDay && _expanded) ...[
            const Divider(height: 1),
            Material(
              color: colorScheme.surfaceContainerLow,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(12, 4, 12, 12),
                child: Column(
                  children: [
                    CheckboxListTile(
                      key: ValueKey('measurement-picker-all-${template.id}'),
                      dense: true,
                      tristate: true,
                      enabled: availableDayEntries.isNotEmpty,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 24,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(6),
                      ),
                      hoverColor: colorScheme.primaryContainer.withValues(
                        alpha: 0.12,
                      ),
                      value: allDaysChecked
                          ? true
                          : anyDaysChecked
                          ? null
                          : false,
                      onChanged: availableDayEntries.isEmpty
                          ? null
                          : (_) => widget.onDayEntriesChanged(
                              availableDayEntries,
                              !allAvailableDaysSelected,
                            ),
                      title: Text(
                        tr.form_survey_template_all_days(dayEntries.length),
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      subtitle: Text(
                        tr.form_survey_template_select_every_survey,
                      ),
                    ),
                    for (final entry in dayEntries)
                      _DayEntryTile(
                        entry: entry,
                        selected: widget.selectedDayEntries.contains(entry),
                        enabled: availableDayEntries.contains(entry),
                        onChanged: widget.onDayEntryChanged,
                      ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _DayEntryTile extends StatelessWidget {
  const _DayEntryTile({
    required this.entry,
    required this.selected,
    required this.enabled,
    required this.onChanged,
  });

  final SurveyTemplateDayEntry entry;
  final bool selected;
  final bool enabled;
  final void Function(SurveyTemplateDayEntry, bool) onChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final title = Row(
      children: [
        SizedBox(
          width: 64,
          child: Text(
            tr.form_survey_template_day_label(entry.dayIndex + 1),
            style: theme.textTheme.labelMedium?.copyWith(
              color: colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        Expanded(child: Text(entry.title, style: theme.textTheme.bodyMedium)),
      ],
    );
    final shape = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(6),
    );

    if (!enabled) {
      return ListTile(
        key: ValueKey('measurement-picker-day-${entry.dayIndex}'),
        dense: true,
        enabled: false,
        shape: shape,
        tileColor: colorScheme.surfaceContainerHighest.withValues(alpha: 0.45),
        contentPadding: const EdgeInsets.symmetric(horizontal: 24),
        title: title,
        trailing: const _AddedBadge(),
      );
    }

    return CheckboxListTile(
      key: ValueKey('measurement-picker-day-${entry.dayIndex}'),
      dense: true,
      selected: selected,
      shape: shape,
      hoverColor: colorScheme.primaryContainer.withValues(alpha: 0.12),
      selectedTileColor: colorScheme.primaryContainer.withValues(alpha: 0.18),
      value: selected,
      onChanged: (value) => onChanged(entry, value ?? false),
      contentPadding: const EdgeInsets.symmetric(horizontal: 24),
      title: title,
    );
  }
}
