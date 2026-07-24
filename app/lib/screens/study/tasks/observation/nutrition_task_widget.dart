import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:studyu_app/l10n/app_localizations.dart';
import 'package:studyu_app/models/app_state.dart';
import 'package:studyu_app/screens/study/nutrition/daily_recall_entry_view_model.dart';
import 'package:studyu_app/screens/study/nutrition/meal_entry_screen.dart';
import 'package:studyu_app/screens/study/nutrition/template_view_model.dart';
import 'package:studyu_app/util/study_subject_extension.dart';
import 'package:studyu_app/widgets/html_text.dart';
import 'package:studyu_app/widgets/nutrition_summary_card.dart';
import 'package:studyu_app/widgets/save_template_dialog.dart';
import 'package:studyu_core/core.dart';

class NutritionTaskWidget extends StatefulWidget {
  final DailyRecall? existingRecall;
  final NutritionTask? task;
  final CompletionPeriod? completionPeriod;

  const NutritionTaskWidget({
    this.existingRecall,
    this.task,
    this.completionPeriod,
    super.key,
  });

  static MaterialPageRoute<DailyRecall> route({
    DailyRecall? existingRecall,
    NutritionTask? task,
    CompletionPeriod? completionPeriod,
  }) => MaterialPageRoute(
    builder: (_) => NutritionTaskWidget(
      existingRecall: existingRecall,
      task: task,
      completionPeriod: completionPeriod,
    ),
  );

  @override
  State<NutritionTaskWidget> createState() => _NutritionTaskWidgetState();
}

class _NutritionTaskWidgetState extends State<NutritionTaskWidget>
    with WidgetsBindingObserver {
  DailyRecallEntryViewModel? _viewModel;
  late TextEditingController _specialOccasionController;
  VoidCallback? _viewModelListener;
  bool _isCompleting = false;

  bool _requiresDailyCompletion(NutritionTask? task) =>
      task?.requireDailyCompletionConfirmation ?? true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _specialOccasionController = TextEditingController(
      text: widget.existingRecall?.specialOccasion ?? '',
    );
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    _viewModel?.onAppLifecycleStateChanged(state);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _specialOccasionController.dispose();
    if (_viewModelListener != null && _viewModel != null) {
      _viewModel!.removeListener(_viewModelListener!);
    }
    _viewModel?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_viewModel == null) {
      final appState = Provider.of<AppState>(context, listen: false);
      _viewModel = DailyRecallEntryViewModel(
        subject: appState.activeSubject,
        task: widget.task,
        completionPeriod: widget.completionPeriod,
        existingRecall: widget.existingRecall,
      );
      _viewModel!.shouldSaveToDb = appState.trackParticipantProgress;

      _viewModelListener = () {
        if (_viewModel!.recall.specialOccasion != null &&
            _specialOccasionController.text !=
                _viewModel!.recall.specialOccasion) {
          if (_specialOccasionController.text.isEmpty &&
              _viewModel!.recall.specialOccasion!.isNotEmpty) {
            _specialOccasionController.text =
                _viewModel!.recall.specialOccasion!;
          }
        }
      };
      _viewModel!.addListener(_viewModelListener!);
    }

    return ChangeNotifierProvider.value(
      value: _viewModel!,
      child: Consumer<DailyRecallEntryViewModel>(
        builder: (context, model, child) {
          final theme = Theme.of(context);
          final l10n = AppLocalizations.of(context)!;
          final recall = model.recall;

          return PopScope(
            canPop:
                !model.isInTaskMode ||
                (_requiresDailyCompletion(widget.task) &&
                    (widget.task?.minimumMealsRequired == null ||
                        model.meetsMinimumMeals)),
            onPopInvokedWithResult: (bool didPop, _) async {
              if (didPop) return;
              if (model.isInTaskMode && !model.meetsMinimumMeals) {
                final shouldLeave = await showDialog<bool>(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    title: Text(l10n.min_meals_not_met_title),
                    content: Text(
                      l10n.min_meals_not_met_message(
                        widget.task!.minimumMealsRequired!,
                      ),
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.of(ctx).pop(false),
                        child: Text(l10n.cancel),
                      ),
                      TextButton(
                        onPressed: () => Navigator.of(ctx).pop(true),
                        child: Text(l10n.leave_anyway),
                      ),
                    ],
                  ),
                );
                if (shouldLeave != true || !context.mounted) return;
              }
              if (_requiresDailyCompletion(widget.task)) {
                if (context.mounted) Navigator.of(context).pop();
              } else {
                await _leaveWithoutCompletion(model);
              }
            },
            child: Scaffold(
              appBar: _buildAppBar(context, model, l10n),
              body: Column(
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 16),
                          if (widget.task?.header != null) ...[
                            HtmlText(widget.task!.header, centered: true),
                            const SizedBox(height: 16),
                          ],
                          if (model.isInTaskMode &&
                              (widget.task?.instructions?.trim().isNotEmpty ==
                                      true ||
                                  widget.task?.minimumMealsRequired != null))
                            _buildInstructionsCard(context, theme, l10n),
                          _buildMealsSection(
                            context,
                            model,
                            recall,
                            theme,
                            l10n,
                          ),
                          if (recall.meals.isNotEmpty) ...[
                            const SizedBox(height: 16),
                            DailyNutritionSummaryCard(dailyRecall: recall),
                          ],
                          if (widget.task?.footer != null) ...[
                            const SizedBox(height: 16),
                            HtmlText(widget.task!.footer, centered: true),
                          ],
                          const SizedBox(height: 24),
                        ],
                      ),
                    ),
                  ),
                  if (model.isInTaskMode &&
                      _requiresDailyCompletion(widget.task))
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text(
                            l10n.finish_nutrition_log_description,
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 8),
                          FilledButton.icon(
                            onPressed:
                                _isCompleting ||
                                    !model.meetsMinimumMeals ||
                                    model.recall.meals.isEmpty
                                ? null
                                : () => _completeTask(model),
                            icon: _isCompleting
                                ? const SizedBox(
                                    width: 18,
                                    height: 18,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                    ),
                                  )
                                : const Icon(Icons.check),
                            label: Text(l10n.finish_nutrition_log),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Future<void> _leaveWithoutCompletion(DailyRecallEntryViewModel model) async {
    if (_isCompleting) return;
    setState(() => _isCompleting = true);
    try {
      await model.flushPendingAutoSave(persistToDatabase: true);
      if (mounted) Navigator.of(context).pop(model.recall);
    } catch (error) {
      if (mounted) {
        setState(() => _isCompleting = false);
        StudyULogger.error('Failed to save nutrition results: $error');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context)!.could_not_save_results),
          ),
        );
      }
    }
  }

  Future<void> _completeTask(DailyRecallEntryViewModel model) async {
    if (_isCompleting ||
        !model.meetsMinimumMeals ||
        model.recall.meals.isEmpty) {
      return;
    }
    setState(() => _isCompleting = true);
    try {
      await model.flushPendingAutoSave();
      final completedRecall = model.markCompleted();
      if (model.shouldSaveToDb && model.subject != null) {
        await model.subject!.upsertNutritionResult(
          taskId: widget.task!.id,
          periodId: widget.completionPeriod!.id,
          recall: completedRecall,
        );
      }
      if (mounted) Navigator.of(context).pop(completedRecall);
    } catch (error) {
      if (mounted) {
        setState(() => _isCompleting = false);
        StudyULogger.error('Failed to save nutrition results: $error');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context)!.could_not_save_results),
          ),
        );
      }
    }
  }

  PreferredSizeWidget _buildAppBar(
    BuildContext context,
    DailyRecallEntryViewModel model,
    AppLocalizations l10n,
  ) {
    final theme = Theme.of(context);
    return AppBar(
      title: Text(widget.task?.title ?? l10n.daily_food_diary),
      actions: [
        Center(
          child: Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Text(
              MaterialLocalizations.of(
                context,
              ).formatMediumDate(model.recall.date),
              style: theme.textTheme.titleSmall,
            ),
          ),
        ),
      ],
      bottom: model.lastSaveTime != null
          ? PreferredSize(
              preferredSize: const Size.fromHeight(32),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 6,
                ),
                color: theme.colorScheme.primaryContainer.withValues(
                  alpha: 0.5,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      model.isSaving ? Icons.cloud_queue : Icons.cloud_done,
                      size: 14,
                      color: theme.colorScheme.onPrimaryContainer,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      model.isSaving
                          ? l10n.saving
                          : l10n.saved_ago(
                              _formatTimeSince(context, model.lastSaveTime!),
                            ),
                      style: TextStyle(
                        fontSize: 12,
                        color: theme.colorScheme.onPrimaryContainer,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            )
          : null,
    );
  }

  Widget _buildInstructionsCard(
    BuildContext context,
    ThemeData theme,
    AppLocalizations l10n,
  ) {
    final instructions = widget.task?.instructions?.trim();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(Icons.info_outline, color: theme.colorScheme.primary),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(l10n.instructions, style: theme.textTheme.titleMedium),
                  if (instructions?.isNotEmpty == true) ...[
                    const SizedBox(height: 8),
                    Text(instructions!),
                  ],
                  if (widget.task?.minimumMealsRequired != null) ...[
                    const SizedBox(height: 8),
                    Text(
                      l10n.min_meals_required(
                        widget.task!.minimumMealsRequired!,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMealsSection(
    BuildContext context,
    DailyRecallEntryViewModel model,
    DailyRecall recall,
    ThemeData theme,
    AppLocalizations l10n,
  ) {
    final customMealTypes =
        widget.task?.customMealTypes?.toSet().toList() ?? [];
    final hasCustomMealTypes = customMealTypes.isNotEmpty;
    final categories = hasCustomMealTypes
        ? [
            for (final label in customMealTypes)
              _MealCategory(
                keyValue: 'custom-$label',
                label: label,
                icon: Icons.restaurant_outlined,
                initialMealType: MealType.other,
                initialCustomMealLabel: label,
                includes: (meal) =>
                    meal.mealType == MealType.other &&
                    meal.customMealLabel == label,
              ),
            if (recall.meals.any(
              (meal) =>
                  meal.mealType != MealType.other ||
                  !customMealTypes.contains(meal.customMealLabel),
            ))
              _MealCategory(
                keyValue: 'legacy-other',
                label: l10n.meal_category_other,
                icon: Icons.restaurant_outlined,
                initialMealType: MealType.other,
                canAdd: false,
                includes: (meal) =>
                    meal.mealType != MealType.other ||
                    !customMealTypes.contains(meal.customMealLabel),
              ),
          ]
        : [
            _MealCategory(
              keyValue: MealType.breakfast.name,
              label: l10n.meal_type_breakfast,
              icon: Icons.wb_sunny_outlined,
              initialMealType: MealType.breakfast,
              includes: (meal) => meal.mealType == MealType.breakfast,
            ),
            _MealCategory(
              keyValue: MealType.lunch.name,
              label: l10n.meal_type_lunch,
              icon: Icons.lunch_dining_outlined,
              initialMealType: MealType.lunch,
              includes: (meal) => meal.mealType == MealType.lunch,
            ),
            _MealCategory(
              keyValue: MealType.dinner.name,
              label: l10n.meal_type_dinner,
              icon: Icons.dinner_dining_outlined,
              initialMealType: MealType.dinner,
              includes: (meal) => meal.mealType == MealType.dinner,
            ),
            _MealCategory(
              keyValue: MealType.snack.name,
              label: l10n.meal_category_snacks,
              icon: Icons.cookie_outlined,
              initialMealType: MealType.snack,
              includes: (meal) => meal.mealType == MealType.snack,
            ),
            _MealCategory(
              keyValue: MealType.other.name,
              label: l10n.meal_category_other,
              icon: Icons.restaurant_outlined,
              initialMealType: MealType.other,
              includes: (meal) =>
                  meal.mealType == MealType.brunch ||
                  meal.mealType == MealType.other,
            ),
          ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              l10n.meals,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            if (widget.task?.minimumMealsRequired != null) ...[
              const SizedBox(width: 8),
              _MinMealsProgressChip(
                current: recall.meals.where((m) => !m.isSkipped).length,
                minimum: widget.task!.minimumMealsRequired!,
                theme: theme,
              ),
            ],
          ],
        ),
        const SizedBox(height: 12),
        for (final category in categories)
          _MealCategorySection(
            category: category,
            entries: [
              for (var index = 0; index < recall.meals.length; index++)
                if (category.includes(recall.meals[index]))
                  (index: index, meal: recall.meals[index]),
            ],
            onAdd: category.canAdd
                ? () => _addMeal(
                    context,
                    model,
                    initialMealType: category.initialMealType,
                    initialCustomMealLabel: category.initialCustomMealLabel,
                  )
                : null,
            onEdit: (meal, index) => _editMeal(context, model, meal, index),
            onSaveTemplate: (meal) => _saveMealAsTemplate(context, meal),
            onDelete: model.removeMeal,
            getMealTypeLabel: (type) => _getMealTypeLabel(context, type),
          ),
        const SizedBox(height: 8),
        SizedBox(
          width: double.infinity,
          child: FilledButton.icon(
            onPressed: () => _addMeal(
              context,
              model,
              initialMealType: hasCustomMealTypes ? MealType.other : null,
              initialCustomMealLabel: hasCustomMealTypes
                  ? customMealTypes.first
                  : null,
            ),
            icon: const Icon(Icons.add),
            label: Text(l10n.log_food),
          ),
        ),
      ],
    );
  }

  Future<void> _addMeal(
    BuildContext context,
    DailyRecallEntryViewModel model, {
    MealType? initialMealType,
    String? initialCustomMealLabel,
  }) async {
    final result = await Navigator.of(context).push(
      MealEntryScreen.route(
        task: widget.task,
        initialMealType: initialMealType,
        initialCustomMealLabel: initialCustomMealLabel,
      ),
    );
    if (result case SavedMealEntryResult(:final meal)) {
      model.addMeal(meal);
    }
  }

  Future<void> _editMeal(
    BuildContext context,
    DailyRecallEntryViewModel model,
    MealLog meal,
    int index,
  ) async {
    final result = await Navigator.of(
      context,
    ).push(MealEntryScreen.route(existingMeal: meal, task: widget.task));
    switch (result) {
      case SavedMealEntryResult(:final meal):
        model.updateMeal(index, meal);
      case DeletedMealEntryResult():
        model.removeMeal(index);
      case null:
        break;
    }
  }

  String _getMealTypeLabel(BuildContext context, MealType type) {
    final l10n = AppLocalizations.of(context)!;
    switch (type) {
      case MealType.breakfast:
        return l10n.meal_type_breakfast;
      case MealType.brunch:
        return l10n.meal_type_brunch;
      case MealType.lunch:
        return l10n.meal_type_lunch;
      case MealType.dinner:
        return l10n.meal_type_dinner;
      case MealType.snack:
        return l10n.meal_type_snack;
      case MealType.other:
        return l10n.meal_type_other;
    }
  }

  String _formatTimeSince(BuildContext context, DateTime time) {
    final l10n = AppLocalizations.of(context)!;
    final diff = DateTime.now().difference(time);
    if (diff.inSeconds < 10) {
      return l10n.just_now;
    } else if (diff.inSeconds < 60) {
      return l10n.seconds_ago(diff.inSeconds);
    } else if (diff.inMinutes < 60) {
      return l10n.minutes_ago(diff.inMinutes);
    } else {
      return l10n.hours_ago(diff.inHours);
    }
  }

  Future<void> _saveMealAsTemplate(BuildContext context, MealLog meal) async {
    if (meal.isSkipped) return;

    final l10n = AppLocalizations.of(context)!;
    final appState = Provider.of<AppState>(context, listen: false);
    final userId = appState.activeSubject?.id ?? 'anonymous';

    final result = await SaveTemplateDialog.show(
      context,
      initialName:
          meal.customMealLabel ?? _getMealTypeLabel(context, meal.mealType),
      templateType: TemplateType.meal,
    );

    if (result != null && context.mounted) {
      final viewModel = TemplateViewModel(userId: userId);
      await viewModel.saveMealAsTemplate(
        name: result.name,
        meal: meal,
        tags: result.tags,
      );

      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(l10n.template_saved)));
      }
    }
  }
}

class _MealCategory {
  final String keyValue;
  final String label;
  final IconData icon;
  final MealType initialMealType;
  final String? initialCustomMealLabel;
  final bool canAdd;
  final bool Function(MealLog) includes;

  const _MealCategory({
    required this.keyValue,
    required this.label,
    required this.icon,
    required this.initialMealType,
    this.initialCustomMealLabel,
    this.canAdd = true,
    required this.includes,
  });
}

class _MealCategorySection extends StatelessWidget {
  final _MealCategory category;
  final List<({int index, MealLog meal})> entries;
  final VoidCallback? onAdd;
  final void Function(MealLog meal, int index) onEdit;
  final ValueChanged<MealLog> onSaveTemplate;
  final ValueChanged<int> onDelete;
  final String Function(MealType) getMealTypeLabel;

  const _MealCategorySection({
    required this.category,
    required this.entries,
    required this.onAdd,
    required this.onEdit,
    required this.onSaveTemplate,
    required this.onDelete,
    required this.getMealTypeLabel,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    if (entries.isEmpty) {
      return Card(
        margin: const EdgeInsets.only(bottom: 8),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          key: ValueKey('empty-meal-category-${category.keyValue}'),
          onTap: onAdd,
          child: ListTile(
            leading: Icon(category.icon, color: theme.colorScheme.primary),
            title: Text(category.label),
            subtitle: Text(l10n.no_foods_added),
            trailing: onAdd == null ? null : const Icon(Icons.add),
          ),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(category.icon, size: 20, color: theme.colorScheme.primary),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  category.label,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              if (onAdd != null)
                IconButton(
                  onPressed: onAdd,
                  icon: const Icon(Icons.add),
                  tooltip: l10n.add_meal,
                ),
            ],
          ),
          for (final entry in entries)
            _MealCard(
              meal: entry.meal,
              index: entry.index,
              onTap: () => onEdit(entry.meal, entry.index),
              onEdit: () => onEdit(entry.meal, entry.index),
              onSaveTemplate: () => onSaveTemplate(entry.meal),
              onDelete: () => onDelete(entry.index),
              getMealTypeLabel: getMealTypeLabel,
            ),
        ],
      ),
    );
  }
}

class _MealCard extends StatelessWidget {
  final MealLog meal;
  final int index;
  final VoidCallback onTap;
  final VoidCallback onEdit;
  final VoidCallback onSaveTemplate;
  final VoidCallback onDelete;
  final String Function(MealType) getMealTypeLabel;

  const _MealCard({
    required this.meal,
    required this.index,
    required this.onTap,
    required this.onEdit,
    required this.onSaveTemplate,
    required this.onDelete,
    required this.getMealTypeLabel,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final foodNames = meal.foods.map((food) => food.name).join(', ');
    final totalEnergy = meal.foods.fold<double>(
      0,
      (sum, food) => sum + food.nutrition.energyKcal,
    );

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              _MealTypeAvatar(meal: meal, getMealTypeLabel: getMealTypeLabel),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      meal.customMealLabel ?? getMealTypeLabel(meal.mealType),
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      meal.isSkipped
                          ? meal.skipReason ?? l10n.skipped_this_meal
                          : foodNames.isEmpty
                          ? l10n.no_foods_added
                          : foodNames,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      meal.foods.isEmpty
                          ? _formatTime(meal.timestamp)
                          : '${_formatTime(meal.timestamp)} • ${l10n.kcal_value(totalEnergy.toStringAsFixed(0))}',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              PopupMenuButton<String>(
                icon: const Icon(Icons.more_vert, size: 20),
                tooltip: l10n.more_options,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                onSelected: (value) {
                  switch (value) {
                    case 'edit':
                      onEdit();
                    case 'save_template':
                      onSaveTemplate();
                    case 'delete':
                      onDelete();
                  }
                },
                itemBuilder: (context) => [
                  PopupMenuItem(
                    value: 'edit',
                    child: _PopupMenuItem(
                      icon: Icons.edit_outlined,
                      label: l10n.edit,
                    ),
                  ),
                  if (meal.foods.isNotEmpty && !meal.isSkipped)
                    PopupMenuItem(
                      value: 'save_template',
                      child: _PopupMenuItem(
                        icon: Icons.bookmark_add_outlined,
                        label: l10n.save_as_template,
                      ),
                    ),
                  PopupMenuItem(
                    value: 'delete',
                    child: _PopupMenuItem(
                      icon: Icons.delete_outline,
                      label: l10n.delete,
                      isDestructive: true,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatTime(DateTime timestamp) {
    return '${timestamp.hour.toString().padLeft(2, '0')}:${timestamp.minute.toString().padLeft(2, '0')}';
  }
}

class _MealTypeAvatar extends StatelessWidget {
  final MealLog meal;
  final String Function(MealType) getMealTypeLabel;

  const _MealTypeAvatar({required this.meal, required this.getMealTypeLabel});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    IconData icon;
    Color color;

    switch (meal.mealType) {
      case MealType.breakfast:
        icon = Icons.wb_sunny_outlined;
        color = Colors.amber;
      case MealType.brunch:
        icon = Icons.brunch_dining_outlined;
        color = Colors.orange;
      case MealType.lunch:
        icon = Icons.lunch_dining_outlined;
        color = Colors.green;
      case MealType.dinner:
        icon = Icons.dinner_dining_outlined;
        color = Colors.indigo;
      case MealType.snack:
        icon = Icons.cookie_outlined;
        color = Colors.purple;
      case MealType.other:
        icon = Icons.restaurant_outlined;
        color = theme.colorScheme.primary;
    }

    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Center(child: Icon(icon, size: 22, color: color)),
    );
  }
}

class _PopupMenuItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isDestructive;

  const _PopupMenuItem({
    required this.icon,
    required this.label,
    this.isDestructive = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(
          icon,
          size: 18,
          color: isDestructive
              ? Theme.of(context).colorScheme.error
              : Theme.of(context).colorScheme.onSurface,
        ),
        const SizedBox(width: 12),
        Text(
          label,
          style: TextStyle(
            color: isDestructive ? Theme.of(context).colorScheme.error : null,
          ),
        ),
      ],
    );
  }
}

class _MinMealsProgressChip extends StatelessWidget {
  final int current;
  final int minimum;
  final ThemeData theme;

  const _MinMealsProgressChip({
    required this.current,
    required this.minimum,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    final met = current >= minimum;
    final color = met ? Colors.green : theme.colorScheme.error;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            met ? Icons.check_circle_outline : Icons.restaurant_menu,
            size: 13,
            color: color,
          ),
          const SizedBox(width: 4),
          Text(
            '$current/$minimum',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
