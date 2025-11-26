import 'package:flutter/material.dart';
import 'package:studyu_app/screens/study/nutrition/food_entry_screen.dart';
import 'package:studyu_app/screens/study/nutrition/meal_entry_screen_helper.dart';
import 'package:studyu_app/widgets/nutrition_summary_card.dart';
import 'package:studyu_core/core.dart';

class MealEntryScreen extends StatefulWidget {
  final MealLog? existingMeal;

  const MealEntryScreen({this.existingMeal, super.key});

  static MaterialPageRoute<MealLog> route({MealLog? existingMeal}) =>
      MaterialPageRoute(
        builder: (_) => MealEntryScreen(existingMeal: existingMeal),
      );

  @override
  State<MealEntryScreen> createState() => _MealEntryScreenState();
}

class _MealEntryScreenState extends State<MealEntryScreen> {
  late MealLog _meal;
  late MealType _mealType;
  late MealContext _mealContext;
  late DateTime _timestamp;
  late bool _isSkipped;
  CompanyContext? _companyContext;
  DistractionContext? _distractionContext;
  String? _customMealLabel;
  String? _locationDescription;
  String? _skipReason;

  @override
  void initState() {
    super.initState();
    if (widget.existingMeal != null) {
      _meal = widget.existingMeal!;
      _mealType = _meal.mealType;
      _mealContext = _meal.mealContext;
      _timestamp = _meal.timestamp;
      _isSkipped = _meal.isSkipped;
      _companyContext = _meal.companyContext;
      _distractionContext = _meal.distractionContext;
      _customMealLabel = _meal.customMealLabel;
      _locationDescription = _meal.locationDescription;
      _skipReason = _meal.skipReason;
    } else {
      _timestamp = DateTime.now();
      _mealType = _getMealTypeByTime(_timestamp);
      _mealContext = MealContext.home;
      _isSkipped = false;
      _meal = MealLog.withId(
        mealType: _mealType,
        mealContext: _mealContext,
        timestamp: _timestamp,
        timezone: DateTime.now().timeZoneName,
        isSkipped: _isSkipped,
        foods: [],
      );
    }
  }

  MealType _getMealTypeByTime(DateTime time) {
    final hour = time.hour;
    if (hour >= 6 && hour < 10) return MealType.breakfast;
    if (hour >= 10 && hour < 12) return MealType.brunch;
    if (hour >= 12 && hour < 16) return MealType.lunch;
    if (hour >= 16 && hour < 21) return MealType.dinner;
    return MealType.snack;
  }

  void _addFood() async {
    final result = await Navigator.of(context).push(
      FoodEntryScreen.route(),
    );
    if (result != null) {
      setState(() {
        _meal.foods.add(result);
      });
    }
  }

  void _editFood(FoodEntry food, int index) async {
    final result = await Navigator.of(context).push(
      FoodEntryScreen.route(existingFood: food),
    );
    if (result != null) {
      setState(() {
        _meal.foods[index] = result;
      });
    }
  }

  void _removeFood(int index) {
    setState(() {
      _meal.foods.removeAt(index);
    });
  }

  void _saveMeal() {
    _meal = MealLog(
      id: _meal.id,
      mealType: _mealType,
      customMealLabel: _customMealLabel,
      mealContext: _mealContext,
      locationDescription: _locationDescription,
      timestamp: _timestamp,
      timezone: DateTime.now().timeZoneName,
      isSkipped: _isSkipped,
      skipReason: _skipReason,
      companyContext: _companyContext,
      distractionContext: _distractionContext,
      foods: _meal.foods,
    );
    Navigator.of(context).pop(_meal);
  }

  Future<void> _selectTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_timestamp),
    );
    if (picked != null) {
      setState(() {
        _timestamp = DateTime(
          _timestamp.year,
          _timestamp.month,
          _timestamp.day,
          picked.hour,
          picked.minute,
        );
      });
    }
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

  String _getMealContextLabel(MealContext context) {
    switch (context) {
      case MealContext.home:
        return 'Home';
      case MealContext.restaurant:
        return 'Restaurant';
      case MealContext.takeout:
        return 'Takeout';
      case MealContext.vending:
        return 'Vending';
      case MealContext.other:
        return 'Other';
    }
  }

  String _getCompanyContextLabel(CompanyContext context) {
    switch (context) {
      case CompanyContext.alone:
        return '👤 Alone';
      case CompanyContext.family:
        return '👨‍👩‍👧‍👦 Family';
      case CompanyContext.friends:
        return '👥 Friends';
      case CompanyContext.colleagues:
        return '💼 Colleagues';
      case CompanyContext.other:
        return '🤝 Other';
    }
  }

  String _getDistractionContextLabel(DistractionContext context) {
    switch (context) {
      case DistractionContext.none:
        return '🧘 None';
      case DistractionContext.tv:
        return '📺 TV';
      case DistractionContext.phone:
        return '📱 Phone';
      case DistractionContext.work:
        return '💻 Work';
      case DistractionContext.other:
        return '📖 Other';
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Meal Entry'),
        actions: [
          if (!_isSkipped && _meal.foods.isNotEmpty ||
              _isSkipped && _skipReason != null)
            TextButton(
              onPressed: _saveMeal,
              style: TextButton.styleFrom(
                foregroundColor: Colors.white,
              ),
              child: const Text('SAVE'),
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
                    Text('Meal Information', style: theme.textTheme.titleLarge),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<MealType>(
                      value: _mealType,
                      decoration: const InputDecoration(
                        labelText: 'Meal Type',
                        border: OutlineInputBorder(),
                      ),
                      items: MealType.values.map((type) {
                        return DropdownMenuItem(
                          value: type,
                          child: Text(_getMealTypeLabel(type)),
                        );
                      }).toList(),
                      onChanged: (value) {
                        if (value != null) {
                          setState(() => _mealType = value);
                        }
                      },
                    ),
                    const SizedBox(height: 16),
                    if (_mealType == MealType.other)
                      TextField(
                        decoration: const InputDecoration(
                          labelText: 'Custom Meal Label',
                          border: OutlineInputBorder(),
                        ),
                        onChanged: (value) => _customMealLabel = value,
                        controller:
                            TextEditingController(text: _customMealLabel ?? ''),
                      ),
                    const SizedBox(height: 16),
                    ListTile(
                      leading: const Icon(Icons.access_time),
                      title: const Text('Time'),
                      subtitle: Text(
                        '${_timestamp.hour.toString().padLeft(2, '0')}:${_timestamp.minute.toString().padLeft(2, '0')}',
                      ),
                      trailing: const Icon(Icons.edit),
                      onTap: _selectTime,
                    ),
                    const Divider(),
                    DropdownButtonFormField<MealContext>(
                      value: _mealContext,
                      decoration: const InputDecoration(
                        labelText: 'Where did you eat?',
                        border: OutlineInputBorder(),
                      ),
                      items: MealContext.values.map((context) {
                        return DropdownMenuItem(
                          value: context,
                          child: Text(_getMealContextLabel(context)),
                        );
                      }).toList(),
                      onChanged: (value) {
                        if (value != null) {
                          setState(() => _mealContext = value);
                        }
                      },
                    ),
                    const SizedBox(height: 16),
                    if (_mealContext == MealContext.other)
                      Column(
                        children: [
                          TextField(
                            decoration: const InputDecoration(
                              labelText: 'Location Description',
                              border: OutlineInputBorder(),
                              hintText: 'Describe where you ate',
                            ),
                            onChanged: (value) => _locationDescription = value,
                            controller:
                                TextEditingController(text: _locationDescription ?? ''),
                          ),
                          const SizedBox(height: 16),
                        ],
                      ),
                    DropdownButtonFormField<CompanyContext>(
                      value: _companyContext,
                      decoration: const InputDecoration(
                        labelText: 'Who were you with?',
                        border: OutlineInputBorder(),
                      ),
                      items: [
                        const DropdownMenuItem(
                          value: null,
                          child: Text('Not specified'),
                        ),
                        ...CompanyContext.values.map((context) {
                          return DropdownMenuItem(
                            value: context,
                            child: Text(_getCompanyContextLabel(context)),
                          );
                        }).toList(),
                      ],
                      onChanged: (value) {
                        setState(() => _companyContext = value);
                      },
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<DistractionContext>(
                      value: _distractionContext,
                      decoration: const InputDecoration(
                        labelText: 'Distractions during meal?',
                        border: OutlineInputBorder(),
                      ),
                      items: [
                        const DropdownMenuItem(
                          value: null,
                          child: Text('Not specified'),
                        ),
                        ...DistractionContext.values.map((context) {
                          return DropdownMenuItem(
                            value: context,
                            child: Text(_getDistractionContextLabel(context)),
                          );
                        }).toList(),
                      ],
                      onChanged: (value) {
                        setState(() => _distractionContext = value);
                      },
                    ),
                    const SizedBox(height: 16),
                    SwitchListTile(
                      title: const Text('Skipped this meal'),
                      value: _isSkipped,
                      onChanged: (value) {
                        setState(() => _isSkipped = value);
                      },
                    ),
                    if (_isSkipped) ...[
                      const SizedBox(height: 8),
                      TextField(
                        decoration: const InputDecoration(
                          labelText: 'Reason for skipping',
                          border: OutlineInputBorder(),
                        ),
                        onChanged: (value) => _skipReason = value,
                        controller:
                            TextEditingController(text: _skipReason ?? ''),
                      ),
                    ],
                  ],
                ),
              ),
            ),
            if (!_isSkipped) ...[
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Food Items (${_meal.foods.length})',
                    style: theme.textTheme.titleLarge,
                  ),
                  ElevatedButton.icon(
                    onPressed: _addFood,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: theme.colorScheme.primary,
                      foregroundColor: theme.colorScheme.onPrimary,
                    ),
                    icon: const Icon(Icons.add),
                    label: const Text('Add Food'),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              if (_meal.foods.isEmpty)
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(32),
                    child: Center(
                      child: Column(
                        children: [
                          Icon(
                            Icons.fastfood,
                            size: 48,
                            color: theme.colorScheme.primary.withOpacity(0.5),
                          ),
                          const SizedBox(height: 8),
                          const Text('No food items yet'),
                        ],
                      ),
                    ),
                  ),
                )
              else
                ...List.generate(_meal.foods.length, (index) {
                  final food = _meal.foods[index];
                  IconData foodIcon;
                  Color? iconColor;
                  switch (food.entryType) {
                    case FoodEntryType.recipe:
                      foodIcon = Icons.menu_book;
                      iconColor = Colors.orange;
                      break;
                    case FoodEntryType.brandedProduct:
                      foodIcon = Icons.shopping_bag;
                      iconColor = Colors.blue;
                      break;
                    case FoodEntryType.manualCustom:
                      foodIcon = Icons.edit_note;
                      iconColor = Colors.purple;
                      break;
                    default:
                      foodIcon = Icons.restaurant;
                      iconColor = Colors.green;
                  }
                  return Card(
                    margin: const EdgeInsets.only(bottom: 8),
                    child: ListTile(
                      leading: Icon(foodIcon, color: iconColor),
                      title: Row(
                        children: [
                          Expanded(child: Text(food.name)),
                          if (food.brandName != null)
                            Chip(
                              label: Text(
                                food.brandName!,
                                style: const TextStyle(fontSize: 10),
                              ),
                              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              visualDensity: VisualDensity.compact,
                            ),
                        ],
                      ),
                      subtitle: Text(
                        '${food.amount} ${food.unit} • ${food.nutrition.energyKcal.toStringAsFixed(0)} kcal\n${getEntryTypeLabel(food.entryType)}',
                      ),
                      isThreeLine: true,
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
                                Text(
                                  'Delete',
                                  style: TextStyle(color: Colors.red),
                                ),
                              ],
                            ),
                          ),
                        ],
                        onSelected: (value) {
                          if (value == 'edit') {
                            _editFood(food, index);
                          } else if (value == 'delete') {
                            _removeFood(index);
                          }
                        },
                      ),
                      onTap: () => _editFood(food, index),
                    ),
                  );
                }),
              
              // Add nutrition summary if there are foods
              if (_meal.foods.isNotEmpty) ...[
                const SizedBox(height: 24),
                MealNutritionSummaryCard(meal: _meal),
              ],
            ],
          ],
        ),
      ),
    );
  }
}

