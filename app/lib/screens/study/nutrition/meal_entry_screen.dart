import 'package:flutter/material.dart';
import 'package:studyu_app/l10n/app_localizations.dart';
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

  Future<void> _addFood() async {
    final result = await Navigator.of(context).push(FoodEntryScreen.route());
    if (result != null) {
      setState(() {
        _meal.foods.add(result);
      });
    }
  }

  Future<void> _editFood(FoodEntry food, int index) async {
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

  String _getMealContextLabel(MealContext mealContext) {
    switch (mealContext) {
      case MealContext.home:
        return AppLocalizations.of(context)!.context_home;
      case MealContext.restaurant:
        return AppLocalizations.of(context)!.context_restaurant;
      case MealContext.takeout:
        return AppLocalizations.of(context)!.context_takeout;
      case MealContext.vending:
        return AppLocalizations.of(context)!.context_vending;
      case MealContext.other:
        return AppLocalizations.of(context)!.context_other;
    }
  }

  String _getCompanyContextLabel(CompanyContext companyContext) {
    switch (companyContext) {
      case CompanyContext.alone:
        return AppLocalizations.of(context)!.company_alone;
      case CompanyContext.family:
        return AppLocalizations.of(context)!.company_family;
      case CompanyContext.friends:
        return AppLocalizations.of(context)!.company_friends;
      case CompanyContext.colleagues:
        return AppLocalizations.of(context)!.company_colleagues;
      case CompanyContext.other:
        return AppLocalizations.of(context)!.company_other;
    }
  }

  String _getDistractionContextLabel(DistractionContext distractionContext) {
    switch (distractionContext) {
      case DistractionContext.none:
        return AppLocalizations.of(context)!.distraction_none;
      case DistractionContext.tv:
        return AppLocalizations.of(context)!.distraction_tv;
      case DistractionContext.phone:
        return AppLocalizations.of(context)!.distraction_phone;
      case DistractionContext.work:
        return AppLocalizations.of(context)!.distraction_work;
      case DistractionContext.other:
        return AppLocalizations.of(context)!.distraction_other;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.meal_entry_title),
      ),
      floatingActionButton:
          (!_isSkipped && _meal.foods.isNotEmpty ||
              _isSkipped && _skipReason != null)
          ? FloatingActionButton.extended(
              onPressed: _saveMeal,
              icon: const Icon(Icons.check),
              label: Text(AppLocalizations.of(context)!.save),
            )
          : null,
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
                      AppLocalizations.of(context)!.meal_information,
                      style: theme.textTheme.titleLarge,
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<MealType>(
                      initialValue: _mealType,
                      decoration: InputDecoration(
                        labelText: AppLocalizations.of(
                          context,
                        )!.meal_type_label,
                        border: const OutlineInputBorder(),
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
                        decoration: InputDecoration(
                          labelText: AppLocalizations.of(
                            context,
                          )!.custom_meal_label,
                          border: const OutlineInputBorder(),
                        ),
                        onChanged: (value) => _customMealLabel = value,
                        controller: TextEditingController(
                          text: _customMealLabel ?? '',
                        ),
                      ),
                    const SizedBox(height: 16),
                    ListTile(
                      leading: const Icon(Icons.access_time),
                      title: Text(AppLocalizations.of(context)!.time),
                      subtitle: Text(
                        '${_timestamp.hour.toString().padLeft(2, '0')}:${_timestamp.minute.toString().padLeft(2, '0')}',
                      ),
                      trailing: const Icon(Icons.edit),
                      onTap: _selectTime,
                    ),
                    const Divider(),
                    DropdownButtonFormField<MealContext>(
                      initialValue: _mealContext,
                      decoration: InputDecoration(
                        labelText: AppLocalizations.of(
                          context,
                        )!.where_did_you_eat,
                        border: const OutlineInputBorder(),
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
                            decoration: InputDecoration(
                              labelText: AppLocalizations.of(
                                context,
                              )!.location_description,
                              border: const OutlineInputBorder(),
                              hintText: AppLocalizations.of(
                                context,
                              )!.location_description_hint,
                            ),
                            onChanged: (value) => _locationDescription = value,
                            controller: TextEditingController(
                              text: _locationDescription ?? '',
                            ),
                          ),
                          const SizedBox(height: 16),
                        ],
                      ),
                    DropdownButtonFormField<CompanyContext>(
                      initialValue: _companyContext,
                      decoration: InputDecoration(
                        labelText: AppLocalizations.of(
                          context,
                        )!.who_were_you_with,
                        border: const OutlineInputBorder(),
                      ),
                      items: [
                        DropdownMenuItem(
                          child: Text(
                            AppLocalizations.of(context)!.not_specified,
                          ),
                        ),
                        ...CompanyContext.values.map((context) {
                          return DropdownMenuItem(
                            value: context,
                            child: Text(_getCompanyContextLabel(context)),
                          );
                        }),
                      ],
                      onChanged: (value) {
                        setState(() => _companyContext = value);
                      },
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<DistractionContext>(
                      initialValue: _distractionContext,
                      decoration: InputDecoration(
                        labelText: AppLocalizations.of(
                          context,
                        )!.distractions_during_meal,
                        border: const OutlineInputBorder(),
                      ),
                      items: [
                        DropdownMenuItem(
                          child: Text(
                            AppLocalizations.of(context)!.not_specified,
                          ),
                        ),
                        ...DistractionContext.values.map((context) {
                          return DropdownMenuItem(
                            value: context,
                            child: Text(_getDistractionContextLabel(context)),
                          );
                        }),
                      ],
                      onChanged: (value) {
                        setState(() => _distractionContext = value);
                      },
                    ),
                    const SizedBox(height: 16),
                    SwitchListTile(
                      title: Text(
                        AppLocalizations.of(context)!.skipped_this_meal,
                      ),
                      value: _isSkipped,
                      onChanged: (value) {
                        setState(() => _isSkipped = value);
                      },
                    ),
                    if (_isSkipped) ...[
                      const SizedBox(height: 8),
                      TextField(
                        decoration: InputDecoration(
                          labelText: AppLocalizations.of(
                            context,
                          )!.reason_for_skipping,
                          border: const OutlineInputBorder(),
                        ),
                        onChanged: (value) => _skipReason = value,
                        controller: TextEditingController(
                          text: _skipReason ?? '',
                        ),
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
                    AppLocalizations.of(
                      context,
                    )!.food_items_section(_meal.foods.length),
                    style: theme.textTheme.titleLarge,
                  ),
                  ElevatedButton.icon(
                    onPressed: _addFood,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: theme.colorScheme.primary,
                      foregroundColor: theme.colorScheme.onPrimary,
                    ),
                    icon: const Icon(Icons.add),
                    label: Text(AppLocalizations.of(context)!.add_food),
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
                          Text(AppLocalizations.of(context)!.no_food_items_yet),
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
                    case FoodEntryType.brandedProduct:
                      foodIcon = Icons.shopping_bag;
                      iconColor = Colors.blue;
                    case FoodEntryType.manualCustom:
                      foodIcon = Icons.edit_note;
                      iconColor = Colors.purple;
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
                              materialTapTargetSize:
                                  MaterialTapTargetSize.shrinkWrap,
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
                          PopupMenuItem(
                            value: 'edit',
                            child: Row(
                              children: [
                                const Icon(Icons.edit),
                                const SizedBox(width: 8),
                                Text(AppLocalizations.of(context)!.edit),
                              ],
                            ),
                          ),
                          PopupMenuItem(
                            value: 'delete',
                            child: Row(
                              children: [
                                const Icon(Icons.delete, color: Colors.red),
                                const SizedBox(width: 8),
                                Text(
                                  AppLocalizations.of(context)!.delete,
                                  style: const TextStyle(color: Colors.red),
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
