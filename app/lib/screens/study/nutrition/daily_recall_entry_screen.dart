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

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now().subtract(const Duration(days: 30)),
      lastDate: DateTime.now().add(const Duration(days: 1)),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
        _recall = DailyRecall(
          id: _recall.id,
          date: _selectedDate,
          isUsualIntakeDay: _isUsualIntakeDay,
          specialOccasion: _specialOccasion,
          recallMode: _recallMode,
          entryStartedAt: _recall.entryStartedAt,
          entryCompletedAt: _recall.entryCompletedAt,
          meals: _recall.meals,
        );
      });
    }
  }

  Future<void> _addMeal() async {
    final result = await Navigator.of(context).push(
      MealEntryScreen.route(),
    );
    if (result != null) {
      setState(() {
        _recall.meals.add(result);
      });
    }
  }

  Future<void> _editMeal(MealLog meal, int index) async {
    final result = await Navigator.of(context).push(
      MealEntryScreen.route(existingMeal: meal),
    );
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
      appBar: AppBar(
        title: const Text('Daily Food Diary'),
        actions: [
          if (_recall.meals.isNotEmpty)
            TextButton(
              onPressed: _completeRecall,
              style: TextButton.styleFrom(
                foregroundColor: Colors.white,
              ),
              child: const Text('COMPLETE'),
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Recall Details',
                      style: theme.textTheme.titleLarge,
                    ),
                    const SizedBox(height: 16),
                    ListTile(
                      leading: const Icon(Icons.calendar_today),
                      title: const Text('Date'),
                      subtitle: Text(
                        '${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}',
                      ),
                      trailing: const Icon(Icons.edit),
                      onTap: _selectDate,
                    ),
                    const Divider(),
                    ListTile(
                      leading: const Icon(Icons.access_time),
                      title: const Text('Recall Mode'),
                      subtitle: DropdownButton<RecallMode>(
                        value: _recallMode,
                        isExpanded: true,
                        underline: Container(),
                        items: const [
                          DropdownMenuItem(
                            value: RecallMode.realtimeRecord,
                            child: Text('Real-time Recording'),
                          ),
                          DropdownMenuItem(
                            value: RecallMode.yesterdayRecall,
                            child: Text('Yesterday Recall'),
                          ),
                        ],
                        onChanged: (value) {
                          if (value != null) {
                            setState(() {
                              _recallMode = value;
                            });
                          }
                        },
                      ),
                    ),
                    const Divider(),
                    SwitchListTile(
                      secondary: const Icon(Icons.calendar_month),
                      title: const Text('Usual Intake Day'),
                      subtitle: const Text(
                        'Was this a typical day for your diet?',
                      ),
                      value: _isUsualIntakeDay,
                      onChanged: (value) {
                        setState(() {
                          _isUsualIntakeDay = value;
                          if (value == true) {
                            _specialOccasion = null;
                          }
                        });
                      },
                    ),
                    if (_isUsualIntakeDay == false) ...[
                      const Divider(),
                      TextField(
                        decoration: const InputDecoration(
                          labelText: 'Special Occasion',
                          hintText: 'e.g., Birthday, Holiday, etc.',
                          border: OutlineInputBorder(),
                        ),
                        onChanged: (value) {
                          _specialOccasion = value.isEmpty ? null : value;
                        },
                        controller: TextEditingController(
                          text: _specialOccasion ?? '',
                        ),
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
                  'Meals (${_recall.meals.length})',
                  style: theme.textTheme.titleLarge,
                ),
                ElevatedButton.icon(
                  onPressed: _addMeal,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: theme.colorScheme.primary,
                    foregroundColor: theme.colorScheme.onPrimary,
                  ),
                  icon: const Icon(Icons.add),
                  label: const Text('Add Meal'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (_recall.meals.isEmpty)
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(32),
                  child: Center(
                    child: Column(
                      children: [
                        Icon(
                          Icons.restaurant,
                          size: 48,
                          color: theme.colorScheme.primary.withOpacity(0.5),
                        ),
                        const SizedBox(height: 8),
                        const Text('No meals recorded yet'),
                      ],
                    ),
                  ),
                ),
              )
            else
              ...List.generate(_recall.meals.length, (index) {
                final meal = _recall.meals[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: ListTile(
                    leading: CircleAvatar(
                      child: Text('${meal.foods.length}'),
                    ),
                    title: Text(
                      meal.customMealLabel ?? _getMealTypeLabel(meal.mealType),
                    ),
                    subtitle: Text(
                      '${meal.foods.length} food items • ${meal.timestamp.hour.toString().padLeft(2, '0')}:${meal.timestamp.minute.toString().padLeft(2, '0')}',
                    ),
                    trailing: PopupMenuButton(
                      itemBuilder: (context) => [
                        const PopupMenuItem(
                          value: 'edit',
                          child: Row(
                            children: [
                              Icon(Icons.edit),
                              SizedBox(width: 8),
                              Text('Edit'),
                            ],
                          ),
                        ),
                        const PopupMenuItem(
                          value: 'delete',
                          child: Row(
                            children: [
                              Icon(Icons.delete, color: Colors.red),
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
                    onTap: () => _editMeal(meal, index),
                  ),
                );
              }),
            
            // Add nutrition summary if there are meals
            if (_recall.meals.isNotEmpty) ...[
              const SizedBox(height: 24),
              DailyNutritionSummaryCard(dailyRecall: _recall),
            ],
          ],
        ),
      ),
    );
  }
}

