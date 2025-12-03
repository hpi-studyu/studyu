import 'package:flutter/material.dart';
import 'package:studyu_app/screens/study/nutrition/food_entry_screen.dart';

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
  final _formKey = GlobalKey<FormState>();
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
    final result = await Navigator.of(context).push(FoodEntryScreen.route());
    if (result != null) {
      setState(() {
        _meal.foods.add(result);
      });
    }
  }

  void _editFood(FoodEntry food, int index) async {
    final result = await Navigator.of(
      context,
    ).push(FoodEntryScreen.route(existingFood: food));
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
    if (!_formKey.currentState!.validate()) return;

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
      appBar: AppBar(title: const Text('Meal Entry')),
      floatingActionButton: _buildFloatingActionButton(theme),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Meal Type Section
              Text('Meal Type', style: theme.textTheme.titleMedium),
              const SizedBox(height: 8),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: MealType.values.map((type) {
                    final isSelected = _mealType == type;
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: ChoiceChip(
                        label: Text(_getMealTypeLabel(type)),
                        selected: isSelected,
                        onSelected: (selected) {
                          if (selected) {
                            setState(() => _mealType = type);
                          }
                        },
                      ),
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: 16),
              if (_mealType == MealType.other) ...[
                TextFormField(
                  decoration: const InputDecoration(
                    labelText: 'Custom Meal Label',
                    border: OutlineInputBorder(),
                  ),
                  onChanged: (value) => _customMealLabel = value,
                  controller: TextEditingController(
                    text: _customMealLabel ?? '',
                  ),
                  validator: (value) {
                    if (_mealType == MealType.other &&
                        (value == null || value.isEmpty)) {
                      return 'Please enter a label';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
              ],

              // Time Section
              InkWell(
                onTap: _selectTime,
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    border: Border.all(color: theme.colorScheme.outline),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.access_time),
                      const SizedBox(width: 16),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Time', style: theme.textTheme.labelMedium),
                          Text(
                            '${_timestamp.hour.toString().padLeft(2, '0')}:${_timestamp.minute.toString().padLeft(2, '0')}',
                            style: theme.textTheme.titleMedium,
                          ),
                        ],
                      ),
                      const Spacer(),
                      const Icon(Icons.edit, size: 20),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Context Section
              ExpansionTile(
                title: const Text('Context & Environment'),
                leading: const Icon(Icons.place),
                childrenPadding: const EdgeInsets.all(16),
                children: [
                  // Location
                  Text('Where did you eat?', style: theme.textTheme.labelLarge),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    children: MealContext.values.map((context) {
                      return ChoiceChip(
                        label: Text(_getMealContextLabel(context)),
                        selected: _mealContext == context,
                        onSelected: (selected) {
                          if (selected) {
                            setState(() => _mealContext = context);
                          }
                        },
                      );
                    }).toList(),
                  ),
                  if (_mealContext == MealContext.other) ...[
                    const SizedBox(height: 8),
                    TextFormField(
                      decoration: const InputDecoration(
                        labelText: 'Location Description',
                        border: OutlineInputBorder(),
                      ),
                      onChanged: (value) => _locationDescription = value,
                      controller: TextEditingController(
                        text: _locationDescription ?? '',
                      ),
                      validator: (value) {
                        if (_mealContext == MealContext.other &&
                            (value == null || value.isEmpty)) {
                          return 'Please describe the location';
                        }
                        return null;
                      },
                    ),
                  ],
                  const SizedBox(height: 16),

                  // Company
                  Text('Who were you with?', style: theme.textTheme.labelLarge),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    children: [
                      ChoiceChip(
                        label: const Text('Not specified'),
                        selected: _companyContext == null,
                        onSelected: (selected) {
                          if (selected) setState(() => _companyContext = null);
                        },
                      ),
                      ...CompanyContext.values.map((context) {
                        return ChoiceChip(
                          label: Text(_getCompanyContextLabel(context)),
                          selected: _companyContext == context,
                          onSelected: (selected) {
                            if (selected)
                              setState(() => _companyContext = context);
                          },
                        );
                      }),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Distractions
                  Text('Distractions?', style: theme.textTheme.labelLarge),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    children: [
                      ChoiceChip(
                        label: const Text('Not specified'),
                        selected: _distractionContext == null,
                        onSelected: (selected) {
                          if (selected)
                            setState(() => _distractionContext = null);
                        },
                      ),
                      ...DistractionContext.values.map((context) {
                        return ChoiceChip(
                          label: Text(_getDistractionContextLabel(context)),
                          selected: _distractionContext == context,
                          onSelected: (selected) {
                            if (selected)
                              setState(() => _distractionContext = context);
                          },
                        );
                      }),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Skipped Section
              SwitchListTile(
                title: const Text('Skipped this meal'),
                value: _isSkipped,
                onChanged: (value) {
                  setState(() => _isSkipped = value);
                },
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(color: theme.colorScheme.outlineVariant),
                ),
              ),
              if (_isSkipped) ...[
                const SizedBox(height: 16),
                TextFormField(
                  decoration: const InputDecoration(
                    labelText: 'Reason for skipping',
                    border: OutlineInputBorder(),
                  ),
                  onChanged: (value) => _skipReason = value,
                  controller: TextEditingController(text: _skipReason ?? ''),
                  validator: (value) {
                    if (_isSkipped && (value == null || value.isEmpty)) {
                      return 'Please provide a reason';
                    }
                    return null;
                  },
                ),
              ],

              // Foods Section
              if (!_isSkipped) ...[
                const SizedBox(height: 32),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Food Items (${_meal.foods.length})',
                      style: theme.textTheme.titleLarge,
                    ),
                    FilledButton.icon(
                      onPressed: _addFood,
                      icon: const Icon(Icons.add),
                      label: const Text('Add Food'),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                if (_meal.foods.isEmpty)
                  Container(
                    padding: const EdgeInsets.all(32),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surfaceContainer,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: theme.colorScheme.outlineVariant,
                      ),
                    ),
                    child: Column(
                      children: [
                        Icon(
                          Icons.fastfood,
                          size: 48,
                          color: theme.colorScheme.primary.withOpacity(0.5),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No food items yet',
                          style: theme.textTheme.titleMedium?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
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
                      elevation: 0,
                      margin: const EdgeInsets.only(bottom: 8),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: BorderSide(
                          color: theme.colorScheme.outlineVariant,
                        ),
                      ),
                      child: ListTile(
                        leading: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: iconColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(foodIcon, color: iconColor),
                        ),
                        title: Text(
                          food.name,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text(
                          '${food.amount} ${food.unit} • ${food.nutrition.energyKcal.round()} kcal',
                        ),
                        trailing: PopupMenuButton(
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
                                  Icon(
                                    Icons.delete,
                                    color: Colors.red,
                                    size: 20,
                                  ),
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
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget? _buildFloatingActionButton(ThemeData theme) {
    // Show button if we have foods OR if we are skipping
    // Validation will happen on press
    if (!_isSkipped && _meal.foods.isNotEmpty || _isSkipped) {
      return FloatingActionButton.extended(
        onPressed: _saveMeal,
        icon: const Icon(Icons.check),
        label: const Text('Save'),
      );
    }
    return null;
  }
}
