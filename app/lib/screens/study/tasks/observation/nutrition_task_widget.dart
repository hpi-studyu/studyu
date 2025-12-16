import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:studyu_app/l10n/app_localizations.dart';
import 'package:studyu_app/models/app_state.dart';
import 'package:studyu_app/screens/study/nutrition/daily_recall_entry_view_model.dart';
import 'package:studyu_app/screens/study/nutrition/meal_entry_screen.dart';
import 'package:studyu_app/widgets/html_text.dart';
import 'package:studyu_app/widgets/nutrition_summary_card.dart';
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
  bool _instructionsExpanded = true;
  DailyRecallEntryViewModel? _viewModel;
  late TextEditingController _specialOccasionController;
  VoidCallback? _viewModelListener;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    // Initialize controller with existing value if any
    _specialOccasionController = TextEditingController(
      text: widget.existingRecall?.specialOccasion ?? '',
    );
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (mounted) {
      // Lifecycle logic handled in VM
    }
    _viewModel?.onAppLifecycleStateChanged(state);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // VM initialization handled in build via _vmAllocated check
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
          final recall = model.recall;

          return Scaffold(
            appBar: AppBar(
              title: Text(
                widget.task?.title ??
                    AppLocalizations.of(context)!.daily_food_diary,
              ),
            ),
            body: Column(
              children: [
                if (model.lastSaveTime != null)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    color: Colors.green.shade50,
                    child: Row(
                      children: [
                        Icon(
                          model.isSaving ? Icons.cloud_queue : Icons.cloud_done,
                          size: 16,
                          color: Colors.green.shade700,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          model.isSaving
                              ? AppLocalizations.of(context)!.saving
                              : AppLocalizations.of(context)!.saved_ago(
                                  _formatTimeSince(
                                    context,
                                    model.lastSaveTime!,
                                  ),
                                ),
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.green.shade800,
                          ),
                        ),
                      ],
                    ),
                  ),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (widget.task?.header != null) ...[
                          HtmlText(widget.task!.header, centered: true),
                          const SizedBox(height: 20),
                        ],
                        if (model.isInTaskMode) ...[
                          Card(
                            child: Theme(
                              data: theme.copyWith(
                                dividerColor: Colors.transparent,
                              ),
                              child: ExpansionTile(
                                initiallyExpanded: _instructionsExpanded,
                                onExpansionChanged: (expanded) {
                                  setState(() {
                                    _instructionsExpanded = expanded;
                                  });
                                },
                                leading: Icon(
                                  Icons.info_outline,
                                  color: theme.colorScheme.primary,
                                ),
                                title: Text(
                                  AppLocalizations.of(context)!.instructions,
                                  style: theme.textTheme.titleLarge?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.fromLTRB(
                                      16,
                                      0,
                                      16,
                                      16,
                                    ),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          widget.task!.instructions ??
                                              AppLocalizations.of(
                                                context,
                                              )!.nutrition_instructions_default,
                                          style: theme.textTheme.bodyMedium,
                                        ),
                                        if (widget.task!.minimumMealsRequired !=
                                            null) ...[
                                          const SizedBox(height: 12),
                                          Container(
                                            padding: const EdgeInsets.all(12),
                                            decoration: BoxDecoration(
                                              color: theme
                                                  .colorScheme
                                                  .primaryContainer,
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                            ),
                                            child: Row(
                                              children: [
                                                Icon(
                                                  Icons.restaurant,
                                                  color: theme
                                                      .colorScheme
                                                      .onPrimaryContainer,
                                                ),
                                                const SizedBox(width: 8),
                                                Expanded(
                                                  child: Text(
                                                    AppLocalizations.of(
                                                      context,
                                                    )!.min_meals_required(
                                                      widget
                                                          .task!
                                                          .minimumMealsRequired!,
                                                    ),
                                                    style: TextStyle(
                                                      color: theme
                                                          .colorScheme
                                                          .onPrimaryContainer,
                                                      fontWeight:
                                                          FontWeight.w500,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                        ],
                        Card(
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  AppLocalizations.of(context)!.recall_details,
                                  style: theme.textTheme.titleLarge,
                                ),
                                const SizedBox(height: 16),
                                ListTile(
                                  leading: const Icon(Icons.calendar_today),
                                  title: Text(
                                    AppLocalizations.of(context)!.date,
                                  ),
                                  subtitle: Text(
                                    '${recall.date.day}/${recall.date.month}/${recall.date.year}',
                                  ),
                                  trailing: const Icon(Icons.edit),
                                  onTap: () => _selectDate(context, model),
                                ),
                                const Divider(),
                                ListTile(
                                  leading: const Icon(Icons.access_time),
                                  title: Text(
                                    AppLocalizations.of(context)!.recall_mode,
                                  ),
                                  subtitle: DropdownButton<RecallMode>(
                                    value: recall.recallMode,
                                    isExpanded: true,
                                    underline: Container(),
                                    items: [
                                      DropdownMenuItem(
                                        value: RecallMode.realtimeRecord,
                                        child: Text(
                                          AppLocalizations.of(
                                            context,
                                          )!.recall_mode_realtime,
                                        ),
                                      ),
                                      DropdownMenuItem(
                                        value: RecallMode.yesterdayRecall,
                                        child: Text(
                                          AppLocalizations.of(
                                            context,
                                          )!.recall_mode_yesterday,
                                        ),
                                      ),
                                    ],
                                    onChanged: (value) {
                                      if (value != null) {
                                        model.updateRecallMode(value);
                                      }
                                    },
                                  ),
                                ),
                                const Divider(),
                                SwitchListTile(
                                  secondary: const Icon(Icons.calendar_month),
                                  title: Text(
                                    AppLocalizations.of(
                                      context,
                                    )!.usual_intake_day,
                                  ),
                                  subtitle: Text(
                                    AppLocalizations.of(
                                      context,
                                    )!.usual_intake_question,
                                  ),
                                  value: recall.isUsualIntakeDay ?? true,
                                  onChanged: (value) {
                                    model.updateUsualIntake(value);
                                    if (value) {
                                      _specialOccasionController.clear();
                                    }
                                  },
                                ),
                                if (recall.isUsualIntakeDay == false) ...[
                                  const Divider(),
                                  TextField(
                                    decoration: InputDecoration(
                                      labelText: AppLocalizations.of(
                                        context,
                                      )!.special_occasion,
                                      hintText: AppLocalizations.of(
                                        context,
                                      )!.special_occasion_hint,
                                      border: const OutlineInputBorder(),
                                    ),
                                    onChanged: (value) {
                                      model.updateSpecialOccasion(
                                        value.isEmpty ? null : value,
                                      );
                                    },
                                    controller: _specialOccasionController,
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              AppLocalizations.of(
                                context,
                              )!.meals_count(recall.meals.length),
                              style: theme.textTheme.titleLarge,
                            ),
                            ElevatedButton.icon(
                              onPressed: () => _addMeal(context, model),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: theme.colorScheme.primary,
                                foregroundColor: theme.colorScheme.onPrimary,
                              ),
                              icon: const Icon(Icons.add),
                              label: Text(
                                AppLocalizations.of(context)!.add_meal,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        if (recall.meals.isEmpty)
                          Card(
                            child: Padding(
                              padding: const EdgeInsets.all(32),
                              child: Center(
                                child: Column(
                                  children: [
                                    Icon(
                                      Icons.restaurant,
                                      size: 48,
                                      color: theme.colorScheme.primary
                                          .withValues(alpha: 0.5),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      AppLocalizations.of(
                                        context,
                                      )!.no_meals_recorded,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          )
                        else
                          ...List.generate(recall.meals.length, (index) {
                            final meal = recall.meals[index];
                            return Card(
                              margin: const EdgeInsets.only(bottom: 8),
                              child: ListTile(
                                leading: CircleAvatar(
                                  child: Text('${meal.foods.length}'),
                                ),
                                title: Text(
                                  meal.customMealLabel ??
                                      _getMealTypeLabel(context, meal.mealType),
                                ),
                                subtitle: Text(
                                  '${AppLocalizations.of(context)!.food_items_count(meal.foods.length)} • ${meal.timestamp.hour.toString().padLeft(2, '0')}:${meal.timestamp.minute.toString().padLeft(2, '0')}',
                                ),
                                trailing: PopupMenuButton(
                                  itemBuilder: (context) => [
                                    PopupMenuItem(
                                      value: 'edit',
                                      child: Row(
                                        children: [
                                          const Icon(Icons.edit),
                                          const SizedBox(width: 8),
                                          Text(
                                            AppLocalizations.of(context)!.edit,
                                          ),
                                        ],
                                      ),
                                    ),
                                    PopupMenuItem(
                                      value: 'delete',
                                      child: Row(
                                        children: [
                                          const Icon(
                                            Icons.delete,
                                            color: Colors.red,
                                          ),
                                          const SizedBox(width: 8),
                                          Text(
                                            AppLocalizations.of(
                                              context,
                                            )!.delete,
                                            style: const TextStyle(
                                              color: Colors.red,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                  onSelected: (value) {
                                    if (value == 'edit') {
                                      _editMeal(context, model, meal, index);
                                    } else if (value == 'delete') {
                                      model.removeMeal(index);
                                    }
                                  },
                                ),
                                onTap: () =>
                                    _editMeal(context, model, meal, index),
                              ),
                            );
                          }),
                        if (recall.meals.isNotEmpty) ...[
                          const SizedBox(height: 24),
                          DailyNutritionSummaryCard(dailyRecall: recall),
                        ],
                        if (widget.task?.footer != null) ...[
                          const SizedBox(height: 20),
                          HtmlText(widget.task!.footer, centered: true),
                        ],
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Future<void> _selectDate(
    BuildContext context,
    DailyRecallEntryViewModel model,
  ) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: model.recall.date,
      firstDate: DateTime.now().subtract(const Duration(days: 30)),
      lastDate: DateTime.now().add(const Duration(days: 1)),
    );
    if (picked != null) {
      model.updateDate(picked);
    }
  }

  Future<void> _addMeal(
    BuildContext context,
    DailyRecallEntryViewModel model,
  ) async {
    final result = await Navigator.of(context).push(MealEntryScreen.route());
    if (result != null) {
      model.addMeal(result);
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
    ).push(MealEntryScreen.route(existingMeal: meal));
    if (result != null) {
      model.updateMeal(index, result);
    }
  }

  String _getMealTypeLabel(BuildContext context, MealType type) {
    switch (type) {
      case MealType.breakfast:
        return AppLocalizations.of(context)!.meal_type_breakfast;
      case MealType.brunch:
        return AppLocalizations.of(context)!.meal_type_brunch;
      case MealType.lunch:
        return AppLocalizations.of(context)!.meal_type_lunch;
      case MealType.dinner:
        return AppLocalizations.of(context)!.meal_type_dinner;
      case MealType.snack:
        return AppLocalizations.of(context)!.meal_type_snack;
      case MealType.other:
        return AppLocalizations.of(context)!.meal_type_other;
    }
  }

  String _formatTimeSince(BuildContext context, DateTime time) {
    final diff = DateTime.now().difference(time);
    if (diff.inSeconds < 10) {
      return AppLocalizations.of(context)!.just_now;
    } else if (diff.inSeconds < 60) {
      return AppLocalizations.of(context)!.seconds_ago(diff.inSeconds);
    } else if (diff.inMinutes < 60) {
      return AppLocalizations.of(context)!.minutes_ago(diff.inMinutes);
    } else {
      return AppLocalizations.of(context)!.hours_ago(diff.inHours);
    }
  }
}
