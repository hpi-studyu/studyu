import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:studyu_app/l10n/app_localizations.dart';
import 'package:studyu_app/models/app_state.dart';
import 'package:studyu_app/screens/study/nutrition/daily_recall_entry_view_model.dart';
import 'package:studyu_app/screens/study/nutrition/food_library_screen.dart';
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
              floatingActionButton: FloatingActionButton.extended(
                onPressed: () => _addMeal(context, model),
                icon: const Icon(Icons.add),
                label: Text(l10n.log_meal),
              ),
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
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                    child: OutlinedButton.icon(
                      onPressed: () {
                        Navigator.push(context, FoodLibraryScreen.route());
                      },
                      icon: const Icon(Icons.bookmark_outline),
                      label: Text(l10n.my_saved_items),
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
    final entries =
        [
          for (var index = 0; index < recall.meals.length; index++)
            (index: index, meal: recall.meals[index]),
        ]..sort((left, right) {
          final leftTime = _knownTimestamp(left.meal);
          final rightTime = _knownTimestamp(right.meal);
          if (leftTime == null && rightTime == null) {
            return left.index.compareTo(right.index);
          }
          if (leftTime == null) return 1;
          if (rightTime == null) return -1;
          final comparison = leftTime.compareTo(rightTime);
          return comparison == 0
              ? left.index.compareTo(right.index)
              : comparison;
        });

    final groups = _buildTimelineGroups(context, entries);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                l10n.meals,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            if (widget.task?.minimumMealsRequired != null)
              _MinMealsProgressChip(
                current: recall.meals.where((m) => !m.isSkipped).length,
                minimum: widget.task!.minimumMealsRequired!,
                theme: theme,
              ),
          ],
        ),
        const SizedBox(height: 12),
        if (entries.isEmpty)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Text(l10n.no_meals_recorded),
          ),
        for (var groupIndex = 0; groupIndex < groups.length; groupIndex++) ...[
          if (groups[groupIndex].isUnknown &&
              (groupIndex == 0 || !groups[groupIndex - 1].isUnknown))
            Padding(
              padding: const EdgeInsets.only(top: 8, bottom: 8),
              child: Text(
                l10n.time_not_remembered,
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          _MealTimelineGroupHeader(category: groups[groupIndex].category),
          for (final entry in groups[groupIndex].entries)
            _MealTimelineCard(
              key: ValueKey('meal-${entry.meal.id}'),
              meal: entry.meal,
              categoryLabel: groups[groupIndex].category.label,
              onTap: () => _editMeal(context, model, entry.meal),
              onSaveTemplate: () => _saveMealAsTemplate(context, entry.meal),
              onDelete: () => model.removeMealById(entry.meal.id),
            ),
        ],
      ],
    );
  }

  List<_MealTimelineGroup> _buildTimelineGroups(
    BuildContext context,
    List<({int index, MealLog meal})> entries,
  ) {
    final groups = <_MealTimelineGroup>[];
    for (final entry in entries) {
      final isUnknown = _knownTimestamp(entry.meal) == null;
      final category = _timelineCategory(context, entry.meal);
      final previous = groups.isEmpty ? null : groups.last;
      if (previous == null ||
          previous.isUnknown != isUnknown ||
          previous.category.key != category.key) {
        groups.add(
          _MealTimelineGroup(
            category: category,
            isUnknown: isUnknown,
            entries: [entry],
          ),
        );
      } else {
        previous.entries.add(entry);
      }
    }
    return groups;
  }

  _MealTimelineCategory _timelineCategory(BuildContext context, MealLog meal) {
    final l10n = AppLocalizations.of(context)!;
    final customLabel = meal.customMealLabel?.trim();
    if (customLabel?.isNotEmpty == true) {
      return _MealTimelineCategory(
        key: 'custom:$customLabel',
        icon: Icons.restaurant_outlined,
        color: Theme.of(context).colorScheme.primary,
        label: customLabel!,
      );
    }

    switch (meal.mealType) {
      case MealType.breakfast:
        return _MealTimelineCategory(
          key: 'breakfast',
          icon: Icons.breakfast_dining_outlined,
          color: Colors.amber,
          label: l10n.meal_type_breakfast,
        );
      case MealType.brunch:
        return _MealTimelineCategory(
          key: 'brunch',
          icon: Icons.brunch_dining_outlined,
          color: Colors.orange,
          label: l10n.meal_type_brunch,
        );
      case MealType.lunch:
        return _MealTimelineCategory(
          key: 'lunch',
          icon: Icons.lunch_dining_outlined,
          color: Colors.green,
          label: l10n.meal_type_lunch,
        );
      case MealType.dinner:
        return _MealTimelineCategory(
          key: 'dinner',
          icon: Icons.dinner_dining_outlined,
          color: Colors.indigo,
          label: l10n.meal_type_dinner,
        );
      case MealType.snack:
        return _MealTimelineCategory(
          key: 'snack',
          icon: Icons.cookie_outlined,
          color: Colors.purple,
          label: l10n.meal_type_snack,
        );
      case MealType.other:
        return _MealTimelineCategory(
          key: meal.isLabelExplicitlyUnset ? 'meal' : 'other',
          icon: Icons.restaurant_outlined,
          color: Theme.of(context).colorScheme.primary,
          label: meal.isLabelExplicitlyUnset
              ? l10n.meal_neutral_label
              : l10n.meal_type_other,
        );
    }
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
        occurrenceDate: model.recall.date,
        openFoodSearch: true,
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
  ) async {
    final result = await Navigator.of(context).push(
      MealEntryScreen.route(
        existingMeal: meal,
        task: widget.task,
        occurrenceDate: model.recall.date,
      ),
    );
    switch (result) {
      case SavedMealEntryResult(:final meal):
        model.updateMealById(meal.id, meal);
      case DeletedMealEntryResult():
        model.removeMealById(meal.id);
      case null:
        break;
    }
  }

  DateTime? _knownTimestamp(MealLog meal) =>
      meal.timePrecision == MealOccurrenceTimePrecision.unknown
      ? null
      : meal.timestamp;

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
          meal.customMealLabel ??
          (meal.mealType == MealType.other
              ? ''
              : _getMealTypeLabel(context, meal.mealType)),
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

class _MealTimelineCategory {
  final String key;
  final IconData icon;
  final Color color;
  final String label;

  const _MealTimelineCategory({
    required this.key,
    required this.icon,
    required this.color,
    required this.label,
  });
}

class _MealTimelineGroup {
  final _MealTimelineCategory category;
  final bool isUnknown;
  final List<({int index, MealLog meal})> entries;

  _MealTimelineGroup({
    required this.category,
    required this.isUnknown,
    required this.entries,
  });
}

class _MealTimelineGroupHeader extends StatelessWidget {
  final _MealTimelineCategory category;

  const _MealTimelineGroupHeader({required this.category});

  @override
  Widget build(BuildContext context) {
    return Semantics(
      container: true,
      label: category.label,
      child: Padding(
        padding: const EdgeInsets.only(top: 8, bottom: 4),
        child: Row(
          children: [
            ExcludeSemantics(
              child: Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: category.color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(category.icon, size: 22, color: category.color),
              ),
            ),
            const SizedBox(width: 12),
            Text(
              category.label,
              style: Theme.of(
                context,
              ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }
}

class _MealTimelineCard extends StatelessWidget {
  final MealLog meal;
  final String categoryLabel;
  final VoidCallback onTap;
  final VoidCallback onSaveTemplate;
  final VoidCallback onDelete;

  const _MealTimelineCard({
    super.key,
    required this.meal,
    required this.categoryLabel,
    required this.onTap,
    required this.onSaveTemplate,
    required this.onDelete,
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
    final time =
        meal.timestamp == null ||
            meal.timePrecision == MealOccurrenceTimePrecision.unknown
        ? l10n.time_not_remembered
        : meal.timePrecision == MealOccurrenceTimePrecision.approximate
        ? l10n.about_time(
            MaterialLocalizations.of(
              context,
            ).formatTimeOfDay(TimeOfDay.fromDateTime(meal.timestamp!)),
          )
        : MaterialLocalizations.of(
            context,
          ).formatTimeOfDay(TimeOfDay.fromDateTime(meal.timestamp!));

    return Semantics(
      container: true,
      label: [
        categoryLabel,
        if (meal.isSkipped)
          l10n.skipped_this_meal
        else if (foodNames.isNotEmpty)
          foodNames
        else
          l10n.no_foods_added,
        time,
        if (meal.isSkipped && meal.skipReason?.trim().isNotEmpty == true)
          meal.skipReason!.trim(),
        if (!meal.isSkipped) l10n.kcal_value(totalEnergy.toStringAsFixed(0)),
      ].join('. '),
      child: Card(
        margin: const EdgeInsets.only(bottom: 8),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        meal.isSkipped
                            ? l10n.skipped_this_meal
                            : foodNames.isEmpty
                            ? l10n.no_foods_added
                            : foodNames,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        [
                          time,
                          if (meal.isSkipped &&
                              meal.skipReason?.trim().isNotEmpty == true)
                            meal.skipReason!.trim(),
                          if (!meal.isSkipped)
                            l10n.kcal_value(totalEnergy.toStringAsFixed(0)),
                        ].join(' • '),
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
                  onSelected: (value) {
                    switch (value) {
                      case 'edit':
                        onTap();
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
      ),
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
    final color = isDestructive
        ? Theme.of(context).colorScheme.error
        : Theme.of(context).colorScheme.onSurface;
    return Row(
      children: [
        Icon(icon, size: 18, color: color),
        const SizedBox(width: 12),
        Text(label, style: TextStyle(color: isDestructive ? color : null)),
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
