import 'package:flutter/material.dart';
import 'package:studyu_app/screens/study/nutrition/meal_entry_screen.dart';
import 'package:studyu_app/widgets/nutrition_summary_card.dart';
import 'package:studyu_core/core.dart';

class DailyRecallEntryScreen extends StatefulWidget {
  final DailyRecall? existingRecall;

  const DailyRecallEntryScreen({this.existingRecall, super.key});

  static MaterialPageRoute<DailyRecall> route({DailyRecall? existingRecall}) =>
      MaterialPageRoute(
        builder: (_) => DailyRecallEntryScreen(existingRecall: existingRecall),
      );

  @override
  State<DailyRecallEntryScreen> createState() => _DailyRecallEntryScreenState();
}

class _DailyRecallEntryScreenState extends State<DailyRecallEntryScreen> {
  late DailyRecall _recall;
  late DateTime _selectedDate;
  late RecallMode _recallMode;
  bool _isUsualIntakeDay = true;
  String? _specialOccasion;

  @override
  void initState() {
    super.initState();
    if (widget.existingRecall != null) {
      _recall = widget.existingRecall!;
      _selectedDate = _recall.date;
      _recallMode = _recall.recallMode;
      _isUsualIntakeDay = _recall.isUsualIntakeDay ?? true;
      _specialOccasion = _recall.specialOccasion;
    } else {
      _selectedDate = DateTime.now();
      _recallMode = RecallMode.realtimeRecord;
      _recall = DailyRecall.withId(
        date: _selectedDate,
        recallMode: _recallMode,
        entryStartedAt: DateTime.now(),
        meals: [],
      );
    }
  }

  void _saveRecall() {
    Navigator.of(context).pop(_recall);
  }

  void _addMeal() async {
    final result = await Navigator.of(context).push(MealEntryScreen.route());
    if (result != null) {
      setState(() {
        _recall.meals.add(result);
      });
    }
  }

  void _editMeal(MealLog meal, int index) async {
    final result = await Navigator.of(
      context,
    ).push(MealEntryScreen.route(existingMeal: meal));
    if (result != null) {
      setState(() {
        _recall.meals[index] = result;
      });
    }
  }

  void _removeMeal(int index) {
    setState(() {
      _recall.meals.removeAt(index);
    });
  }

  void _completeRecall() {
    _recall = DailyRecall(
      id: _recall.id,
      date: _recall.date,
      isUsualIntakeDay: _isUsualIntakeDay,
      specialOccasion: _specialOccasion,
      recallMode: _recallMode,
      entryStartedAt: _recall.entryStartedAt,
      entryCompletedAt: DateTime.now(),
      meals: _recall.meals,
    );
    Navigator.of(context).pop(_recall);
  }

  String _getMealTypeLabel(MealType type) {
    switch (type) {
      case MealType.breakfast:
        return 'Breakfast';
      case MealType.brunch:
        return 'Brunch';
      case MealType.lunch:
        return 'Lunch';
      case MealType.dinner:
        return 'Dinner';
      case MealType.snack:
        return 'Snack';
      case MealType.other:
        return 'Other';
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Daily Food Diary')),
      floatingActionButton: _buildFloatingActionButtons(theme),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Nutrition Summary
            if (_recall.meals.isNotEmpty) ...[
              DailyNutritionSummaryCard(dailyRecall: _recall),
              const SizedBox(height: 24),
            ],

            // Timeline Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Timeline',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                FilledButton.icon(
                  onPressed: _addMeal,
                  icon: const Icon(Icons.add),
                  label: const Text('Add Meal'),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Meals List
            if (_recall.meals.isEmpty)
              _buildEmptyState(theme)
            else
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _recall.meals.length,
                separatorBuilder: (context, index) =>
                    const SizedBox(height: 16),
                itemBuilder: (context, index) {
                  final meal = _recall.meals[index];
                  return _buildMealCard(meal, index, theme);
                },
              ),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(32),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainer,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.colorScheme.outlineVariant),
      ),
      child: Column(
        children: [
          Icon(
            Icons.restaurant_menu,
            size: 48,
            color: theme.colorScheme.primary.withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          Text(
            'No meals recorded yet',
            style: theme.textTheme.titleMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Start by adding your first meal of the day',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildMealCard(MealLog meal, int index, ThemeData theme) {
    final timeString =
        '${meal.timestamp.hour.toString().padLeft(2, '0')}:${meal.timestamp.minute.toString().padLeft(2, '0')}';
    final totalCals = meal.foods.fold<double>(
      0,
      (sum, food) => sum + food.nutrition.energyKcal,
    );

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: theme.colorScheme.outlineVariant),
      ),
      child: InkWell(
        onTap: () => _editMeal(meal, index),
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primaryContainer,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      timeString,
                      style: theme.textTheme.labelMedium?.copyWith(
                        color: theme.colorScheme.onPrimaryContainer,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      meal.customMealLabel ?? _getMealTypeLabel(meal.mealType),
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Text(
                    '${totalCals.round()} kcal',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                  const SizedBox(width: 4),
                  PopupMenuButton(
                    icon: const Icon(Icons.more_vert),
                    itemBuilder: (context) => [
                      const PopupMenuItem(
                        value: 'edit',
                        child: Row(
                          children: [
                            Icon(Icons.edit, size: 20),
                            SizedBox(width: 8),
                            Text('Edit'),
                          ],
                        ),
                      ),
                      const PopupMenuItem(
                        value: 'delete',
                        child: Row(
                          children: [
                            Icon(Icons.delete, color: Colors.red, size: 20),
                            SizedBox(width: 8),
                            Text('Delete', style: TextStyle(color: Colors.red)),
                          ],
                        ),
                      ),
                    ],
                    onSelected: (value) {
                      if (value == 'edit') {
                        _editMeal(meal, index);
                      } else if (value == 'delete') {
                        _removeMeal(index);
                      }
                    },
                  ),
                ],
              ),
              const Divider(height: 24),
              if (meal.foods.isEmpty)
                Text(
                  'No foods added',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                    fontStyle: FontStyle.italic,
                  ),
                )
              else
                ...meal.foods
                    .take(3)
                    .map(
                      (food) => Padding(
                        padding: const EdgeInsets.only(bottom: 4),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.circle,
                              size: 6,
                              color: Colors.grey,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                food.name,
                                style: theme.textTheme.bodyMedium,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            Text(
                              '${food.nutrition.energyKcal.round()} kcal',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
              if (meal.foods.length > 3)
                Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(
                    '+ ${meal.foods.length - 3} more items',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.primary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFloatingActionButtons(ThemeData theme) {
    final showComplete = _recall.meals.isNotEmpty;

    if (!showComplete) {
      return FloatingActionButton.extended(
        heroTag: 'save',
        onPressed: _saveRecall,
        icon: const Icon(Icons.save),
        label: const Text('Save'),
      );
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        FloatingActionButton.extended(
          heroTag: 'save',
          onPressed: _saveRecall,
          backgroundColor: theme.colorScheme.surfaceContainerHigh,
          foregroundColor: theme.colorScheme.onSurface,
          icon: const Icon(Icons.save),
          label: const Text('Save'),
        ),
        const SizedBox(width: 16),
        FloatingActionButton.extended(
          heroTag: 'complete',
          onPressed: _completeRecall,
          icon: const Icon(Icons.check),
          label: const Text('Complete'),
        ),
      ],
    );
  }
}
