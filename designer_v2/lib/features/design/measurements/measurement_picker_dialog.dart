import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:studyu_core/core.dart';
import 'package:studyu_designer_v2/common_views/dialog.dart';
import 'package:studyu_designer_v2/common_views/form_buttons.dart';
import 'package:studyu_designer_v2/common_views/primary_button.dart';
import 'package:studyu_designer_v2/features/design/measurements/measurements_form_controller.dart';
import 'package:studyu_designer_v2/features/design/measurements/survey_template_providers.dart';
import 'package:studyu_designer_v2/localization/app_translation.dart';

class MeasurementSelection {
  const MeasurementSelection.blankSurvey()
    : isBlankSurvey = true,
      includeNutrition = false,
      templates = const [],
      dayEntries = const [];

  const MeasurementSelection.predefined({
    required this.includeNutrition,
    required this.templates,
    required this.dayEntries,
  }) : isBlankSurvey = false;

  final bool isBlankSurvey;
  final bool includeNutrition;
  final List<SurveyTemplate> templates;
  final List<SurveyTemplateDayEntry> dayEntries;
}

enum _MeasurementCategory { all, nutrition }

extension on _MeasurementCategory {
  String get label => switch (this) {
    _MeasurementCategory.all => tr.form_measurement_category_all,
    _MeasurementCategory.nutrition => tr.form_measurement_category_nutrition,
  };

  IconData get icon => switch (this) {
    _MeasurementCategory.all => Icons.grid_view_rounded,
    _MeasurementCategory.nutrition => Icons.restaurant_outlined,
  };

  bool includes(SurveyTemplate template) =>
      this == _MeasurementCategory.all || template.tags.contains(name);
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
    final width = math.min(900.0, viewport.width - 48.0);
    final height = math.min(650.0, viewport.height - 48.0);

    return StandardDialog(
      titleText: tr.form_measurement_type_select,
      width: width,
      height: height,
      minWidth: 0,
      minHeight: 0,
      maxWidth: 900,
      maxHeight: 650,
      scrollBody: false,
      body: FutureBuilder<List<SurveyTemplate>>(
        future: _templates,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          return LayoutBuilder(
            builder: (context, constraints) {
              final templates = snapshot.data ?? [];
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
        },
      ),
      actionButtons: [
        const DismissButton(),
        PrimaryButton(
          text: tr.form_survey_template_add_selected_count(_selectionCount),
          enabled: _hasSelection,
          onPressed: _hasSelection ? _confirmSelection : null,
        ),
      ],
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

  void _confirmSelection() {
    Navigator.of(context).pop(
      MeasurementSelection.predefined(
        includeNutrition: _nutritionSelected,
        templates: _selectedTemplates.toList(),
        dayEntries: _selectedDayEntries.toList(),
      ),
    );
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
              const _CustomSurveyButton(),
              const SizedBox(height: 20),
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
        const _CustomSurveyButton(),
        const SizedBox(height: 16),
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
    this.enabled = true,
    this.clipBehavior = Clip.none,
  });

  final Widget child;
  final VoidCallback? onTap;
  final bool selected;
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

    return ExcludeFocus(
      excluding: !enabled,
      child: Opacity(
        opacity: enabled ? 1 : 0.65,
        child: Card(
          margin: EdgeInsets.zero,
          color: selected
              ? colorScheme.primaryContainer.withValues(alpha: 0.35)
              : Colors.white,
          elevation: 3,
          shadowColor: Colors.black.withValues(alpha: 0.15),
          clipBehavior: clipBehavior,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
            side: selected
                ? BorderSide(color: colorScheme.primary, width: 2)
                : BorderSide.none,
          ),
          child: content,
        ),
      ),
    );
  }
}

class _AddedBadge extends StatelessWidget {
  const _AddedBadge();

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
          tr.form_survey_template_added,
          style: theme.textTheme.labelSmall?.copyWith(
            color: colorScheme.onPrimaryContainer,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}

class _CustomSurveyButton extends StatelessWidget {
  const _CustomSurveyButton();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: PrimaryButton(
        text: tr.form_measurement_type_survey,
        onPressed: () =>
            Navigator.of(context).pop(const MeasurementSelection.blankSurvey()),
      ),
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
    final showNutrition =
        category == _MeasurementCategory.all ||
        category == _MeasurementCategory.nutrition;
    final itemCount = visibleTemplates.length + (showNutrition ? 1 : 0);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (showHeading) ...[
          Text(category.label, style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 12),
        ],
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
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          tr.form_measurement_type_nutrition,
                          style: Theme.of(context).textTheme.bodyLarge,
                        ),
                      ),
                      if (!canAdd) const _AddedBadge(),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(tr.form_measurement_type_nutrition_description),
                ],
              ),
            ),
            if (selected) ...[
              const SizedBox(width: 16),
              Icon(Icons.check_circle_rounded, color: colorScheme.primary),
            ],
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
    final allDaysSelected =
        availableDayEntries.isNotEmpty &&
        selectedDayEntries.length == availableDayEntries.length;
    final anyDaySelected = selectedDayEntries.isNotEmpty;
    final cardSelected = template.isMultiDay ? anyDaySelected : widget.selected;
    final enabled = template.isMultiDay
        ? availableDayEntries.isNotEmpty
        : !_isAlreadyAdded;

    final header = Padding(
      padding: const EdgeInsets.all(16),
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
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        template.title,
                        style: theme.textTheme.bodyLarge?.copyWith(
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    if (!enabled) const _AddedBadge(),
                  ],
                ),
                const SizedBox(height: 4),
                Text(template.description),
                const SizedBox(height: 4),
                Text(
                  template.isMultiDay
                      ? tr.form_survey_template_multi_day_help(
                          dayEntries.length,
                        )
                      : tr.form_survey_template_single_help,
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          if (cardSelected) ...[
            const SizedBox(width: 16),
            Icon(Icons.check_circle_rounded, color: colorScheme.primary),
          ],
          if (template.isMultiDay) ...[
            const SizedBox(width: 8),
            Icon(
              _expanded ? Icons.expand_less_rounded : Icons.expand_more_rounded,
            ),
          ],
        ],
      ),
    );

    return _MeasurementCard(
      selected: cardSelected,
      enabled: enabled,
      onTap: template.isMultiDay
          ? null
          : () => widget.onChanged(template, !widget.selected),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          if (template.isMultiDay)
            InkWell(
              onTap: enabled
                  ? () => setState(() => _expanded = !_expanded)
                  : null,
              child: header,
            )
          else
            header,
          if (template.isMultiDay && _expanded) ...[
            const Divider(height: 1),
            Material(
              color: colorScheme.surfaceContainerLow,
              child: Column(
                children: [
                  CheckboxListTile(
                    dense: true,
                    tristate: true,
                    enabled: availableDayEntries.isNotEmpty,
                    selected: anyDaySelected,
                    hoverColor: colorScheme.primaryContainer.withValues(
                      alpha: 0.25,
                    ),
                    selectedTileColor: colorScheme.primaryContainer.withValues(
                      alpha: 0.35,
                    ),
                    value: allDaysSelected
                        ? true
                        : anyDaySelected
                        ? null
                        : false,
                    onChanged: availableDayEntries.isEmpty
                        ? null
                        : (_) => widget.onDayEntriesChanged(
                            availableDayEntries,
                            !allDaysSelected,
                          ),
                    title: Text(tr.form_survey_template_select_all),
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

    return CheckboxListTile(
      dense: true,
      enabled: enabled,
      selected: selected,
      hoverColor: colorScheme.primaryContainer.withValues(alpha: 0.25),
      selectedTileColor: colorScheme.primaryContainer.withValues(alpha: 0.35),
      value: selected,
      onChanged: enabled ? (value) => onChanged(entry, value ?? false) : null,
      contentPadding: const EdgeInsets.symmetric(horizontal: 24),
      title: Row(
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
          if (!enabled) ...[const SizedBox(width: 8), const _AddedBadge()],
        ],
      ),
    );
  }
}
