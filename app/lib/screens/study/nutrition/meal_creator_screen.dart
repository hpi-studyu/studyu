import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:studyu_app/l10n/app_localizations.dart';
import 'package:studyu_app/models/app_state.dart';
import 'package:studyu_app/screens/study/nutrition/food_item_components.dart';
import 'package:studyu_app/screens/study/nutrition/food_search_screen.dart';
import 'package:studyu_app/screens/study/nutrition/meal_entry_screen_helper.dart';
import 'package:studyu_app/screens/study/nutrition/template_view_model.dart';
import 'package:studyu_app/widgets/nutrition_summary_card.dart';
import 'package:studyu_app/widgets/save_template_dialog.dart';
import 'package:studyu_app/widgets/unsaved_changes_dialog.dart';
import 'package:studyu_core/core.dart';

class MealCreatorScreen extends StatefulWidget {
  final FoodEntry? existingMeal;
  final List<FoodEntry> initialFoods;
  final String? initialName;
  final bool showCurrentDayPropagationOption;
  final bool showCurrentMealOnlyNotice;
  final ValueChanged<bool>? onCurrentDayPropagationChanged;
  final TemplateViewModel? templateViewModel;
  final void Function(FoodEntry food, Offset? source)? onSavedToSelection;

  const MealCreatorScreen({
    this.existingMeal,
    this.initialFoods = const [],
    this.initialName,
    this.showCurrentDayPropagationOption = false,
    this.showCurrentMealOnlyNotice = false,
    this.onCurrentDayPropagationChanged,
    this.templateViewModel,
    this.onSavedToSelection,
    super.key,
  });

  static MaterialPageRoute<FoodEntry> route({
    FoodEntry? existingMeal,
    List<FoodEntry> initialFoods = const [],
    String? initialName,
    bool showCurrentDayPropagationOption = false,
    bool showCurrentMealOnlyNotice = false,
    ValueChanged<bool>? onCurrentDayPropagationChanged,
    TemplateViewModel? templateViewModel,
    void Function(FoodEntry food, Offset? source)? onSavedToSelection,
  }) => MaterialPageRoute(
    builder: (_) => MealCreatorScreen(
      existingMeal: existingMeal,
      initialFoods: initialFoods,
      initialName: initialName,
      showCurrentDayPropagationOption: showCurrentDayPropagationOption,
      showCurrentMealOnlyNotice: showCurrentMealOnlyNotice,
      onCurrentDayPropagationChanged: onCurrentDayPropagationChanged,
      templateViewModel: templateViewModel,
      onSavedToSelection: onSavedToSelection,
    ),
  );

  @override
  State<MealCreatorScreen> createState() => _MealCreatorScreenState();
}

class _MealCreatorScreenState extends State<MealCreatorScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _descriptionController;
  late TextEditingController _servingsController;

  // Meal metadata controllers
  late TextEditingController _rawWeightController;
  late TextEditingController _cookedWeightController;
  late TextEditingController _preparationMethodController;

  // Quick Add controllers
  late TextEditingController _quickNameController;
  late TextEditingController _quickAmountController;
  late TextEditingController _quickCaloriesController;
  bool _showQuickAdd = false;
  bool _updateCurrentDayEntries = false;

  List<FoodComposition> _foods = [];
  final List<FoodEntry> _componentFoods = [];
  PreparationDetails? _preparationDetails;
  NutritionProfile? _cachedNutrition;
  late final String _initialSnapshot;
  bool _allowPop = false;
  final GlobalKey _saveButtonKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    if (widget.existingMeal != null) {
      final meal = widget.existingMeal!;
      _nameController = TextEditingController(text: meal.name);
      _descriptionController = TextEditingController(
        text: meal.description ?? '',
      );
      _servingsController = TextEditingController(text: meal.amount.toString());

      if (meal.preparationDetails != null) {
        _preparationDetails = meal.preparationDetails;
        _rawWeightController = TextEditingController(
          text: _preparationDetails!.rawWeight.toString(),
        );
        _cookedWeightController = TextEditingController(
          text: _preparationDetails!.cookedWeight.toString(),
        );
        _preparationMethodController = TextEditingController(
          text: _preparationDetails!.preparationMethod,
        );
      } else {
        _rawWeightController = TextEditingController();
        _cookedWeightController = TextEditingController();
        _preparationMethodController = TextEditingController();
      }

      final compositions = meal.componentFoods;
      final snapshots = meal.componentSnapshots;
      if (compositions == null ||
          snapshots == null ||
          compositions.length != snapshots.length) {
        throw StateError('Saved meals require complete component snapshots');
      }
      _foods = compositions
          .map((composition) => FoodComposition.fromJson(composition.toJson()))
          .toList();
      _componentFoods.addAll(
        snapshots.map((food) => FoodEntry.fromJson(food.toJson())),
      );
    } else {
      _nameController = TextEditingController(text: widget.initialName ?? '');
      _descriptionController = TextEditingController();
      _servingsController = TextEditingController(text: '1');
      _rawWeightController = TextEditingController();
      _cookedWeightController = TextEditingController();
      _preparationMethodController = TextEditingController();
      _componentFoods.addAll(widget.initialFoods);
      _foods = [
        for (var index = 0; index < widget.initialFoods.length; index++)
          FoodComposition.withId(
            parentEntryId: '',
            foodId: widget.initialFoods[index].foodId,
            amount: widget.initialFoods[index].amount,
            unit: widget.initialFoods[index].unit,
            sortOrder: index,
          ),
      ];
    }

    // Initialize Quick Add controllers
    _quickNameController = TextEditingController();
    _quickAmountController = TextEditingController(text: '1');
    _quickCaloriesController = TextEditingController();
    _initialSnapshot = _snapshot;

    _servingsController.addListener(() {
      setState(() {
        _cachedNutrition = null;
      });
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _servingsController.dispose();
    _rawWeightController.dispose();
    _cookedWeightController.dispose();
    _preparationMethodController.dispose();
    _quickNameController.dispose();
    _quickAmountController.dispose();
    _quickCaloriesController.dispose();
    super.dispose();
  }

  Future<void> _addFood() async {
    final result = await Navigator.of(context).push(
      FoodSearchScreen.route(
        allowMeals: false,
        templateViewModel:
            widget.templateViewModel ??
            Provider.of<TemplateViewModel?>(context, listen: false),
      ),
    );
    if (result != null) {
      setState(() {
        _componentFoods.add(result);
        _foods.add(
          FoodComposition.withId(
            parentEntryId: '',
            foodId: result.foodId,
            amount: result.amount,
            unit: result.unit,
            sortOrder: _foods.length,
          ),
        );
        _cachedNutrition = null;
      });
    }
  }

  void _quickAddFood() {
    final name = _quickNameController.text.trim();
    final amount = double.tryParse(_quickAmountController.text) ?? 1;
    final calories = double.tryParse(_quickCaloriesController.text) ?? 0;

    if (name.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Please enter food name')));
      return;
    }

    final quickFood = FoodEntry.withId(
      entryType: FoodEntryType.manualCustom,
      name: name,
      amount: amount,
      unit: 'serving',
      servingSizeGrams: 100,
      portionEstimationMethod: PortionEstimationMethod.householdMeasure,
      portionState: PortionState.asServed,
      nutrition: NutritionProfile(
        energyKcal: calories,
        protein: 0,
        carbs: 0,
        fat: 0,
        sugars: 0,
        fiber: 0,
        saturatedFat: 0,
        transFat: 0,
        cholesterol: 0,
        sodium: 0,
        waterContent: 0,
        micros: {},
      ),
      source: FoodSource.manual,
      confidenceScore: 0.5,
      originalValues: {},
    );

    setState(() {
      _componentFoods.add(quickFood);
      _foods.add(
        FoodComposition.withId(
          parentEntryId: '',
          foodId: quickFood.foodId,
          amount: amount,
          unit: 'serving',
          sortOrder: _foods.length,
        ),
      );
      _cachedNutrition = null;

      // Clear quick add fields but keep form open for rapid entry
      _quickNameController.clear();
      _quickAmountController.text = '1';
      _quickCaloriesController.clear();
    });
  }

  void _removeFood(int index) {
    setState(() {
      _foods.removeAt(index);
      _componentFoods.removeAt(index);
      _cachedNutrition = null;
    });
  }

  void _updateFoodAmount(int index, double amount, String unit) {
    setState(() {
      _foods[index] = FoodComposition(
        id: _foods[index].id,
        parentEntryId: _foods[index].parentEntryId,
        foodId: _foods[index].foodId,
        amount: amount,
        unit: unit,
        sortOrder: _foods[index].sortOrder,
      );
      _cachedNutrition = null;
    });
  }

  NutritionProfile _calculateTotalNutrition() {
    double totalEnergy = 0;
    double totalProtein = 0;
    double totalCarbs = 0;
    double totalFat = 0;
    double totalSugars = 0;
    double totalFiber = 0;
    double totalSaturatedFat = 0;
    double totalTransFat = 0;
    double totalCholesterol = 0;
    double totalSodium = 0;
    double totalWater = 0;
    final Map<String, double> totalMicros = {};

    for (int i = 0; i < _componentFoods.length; i++) {
      final food = _componentFoods[i];
      final composition = _foods[i];

      final ratio = composition.amount / food.amount;

      totalEnergy += food.nutrition.energyKcal * ratio;
      totalProtein += food.nutrition.protein * ratio;
      totalCarbs += food.nutrition.carbs * ratio;
      totalFat += food.nutrition.fat * ratio;
      totalSugars += food.nutrition.sugars * ratio;
      totalFiber += food.nutrition.fiber * ratio;
      totalSaturatedFat += food.nutrition.saturatedFat * ratio;
      totalTransFat += food.nutrition.transFat * ratio;
      totalCholesterol += food.nutrition.cholesterol * ratio;
      totalSodium += food.nutrition.sodium * ratio;
      totalWater += food.nutrition.waterContent * ratio;

      food.nutrition.micros.forEach((key, value) {
        totalMicros[key] = (totalMicros[key] ?? 0) + (value * ratio);
      });
    }

    final servings = double.tryParse(_servingsController.text) ?? 1;

    return NutritionProfile(
      energyKcal: totalEnergy / servings,
      protein: totalProtein / servings,
      carbs: totalCarbs / servings,
      fat: totalFat / servings,
      sugars: totalSugars / servings,
      fiber: totalFiber / servings,
      saturatedFat: totalSaturatedFat / servings,
      transFat: totalTransFat / servings,
      cholesterol: totalCholesterol / servings,
      sodium: totalSodium / servings,
      waterContent: totalWater / servings,
      micros: totalMicros.map(
        (nutrient, value) => MapEntry(nutrient, value / servings),
      ),
    );
  }

  double _calculateServingSizeGrams() {
    final totalGrams = [
      for (var index = 0; index < _componentFoods.length; index++)
        _componentFoods[index].servingSizeGrams * _foods[index].amount,
    ].fold<double>(0, (total, grams) => total + grams);
    final servings = double.parse(_servingsController.text);
    return totalGrams / servings;
  }

  FoodEntry? _buildMeal() {
    if (!_formKey.currentState!.validate() || _foods.isEmpty) {
      return null;
    }

    final nutrition = _calculateTotalNutrition();
    final servingSizeGrams = _calculateServingSizeGrams();

    PreparationDetails? preparationDetails;
    if (_rawWeightController.text.isNotEmpty &&
        _cookedWeightController.text.isNotEmpty &&
        _preparationMethodController.text.isNotEmpty) {
      final rawWeight = double.parse(_rawWeightController.text);
      final cookedWeight = double.parse(_cookedWeightController.text);
      preparationDetails = PreparationDetails(
        rawWeight: rawWeight,
        cookedWeight: cookedWeight,
        yieldFactor: cookedWeight / rawWeight,
        preparationMethod: _preparationMethodController.text,
        retentionFactors: {},
      );
    }

    final existing = widget.existingMeal;
    final components = [
      for (var index = 0; index < _foods.length; index++)
        FoodComposition(
          id: _foods[index].id,
          parentEntryId: '',
          foodId: _foods[index].foodId,
          amount: _foods[index].amount,
          unit: _foods[index].unit,
          sortOrder: index,
        ),
    ];
    final snapshots = [
      for (var index = 0; index < _componentFoods.length; index++)
        rescaleFoodAmount(_componentFoods[index], _foods[index].amount),
    ];
    final meal = existing == null
        ? FoodEntry.withId(
            entryType: FoodEntryType.meal,
            name: _nameController.text,
            description: _descriptionController.text.isEmpty
                ? null
                : _descriptionController.text,
            amount: double.parse(_servingsController.text),
            unit: 'serving',
            servingSizeGrams: servingSizeGrams,
            portionEstimationMethod: PortionEstimationMethod.householdMeasure,
            portionState: PortionState.cooked,
            nutrition: nutrition,
            source: FoodSource.manual,
            confidenceScore: 0.9,
            originalValues: {},
            preparationDetails: preparationDetails,
            componentFoods: components,
            componentSnapshots: snapshots,
          )
        : FoodEntry(
            id: existing.id,
            foodId: existing.foodId,
            foodVersionId: existing.foodVersionId,
            entryType: FoodEntryType.meal,
            name: _nameController.text,
            brandName: existing.brandName,
            description: _descriptionController.text.isEmpty
                ? null
                : _descriptionController.text,
            amount: double.parse(_servingsController.text),
            unit: existing.unit,
            servingSizeGrams: servingSizeGrams,
            portionReference: existing.portionReference,
            portionEstimationMethod: existing.portionEstimationMethod,
            portionState: existing.portionState,
            yieldFactor: existing.yieldFactor,
            ediblePortion: existing.ediblePortion,
            nutrition: nutrition,
            foodCode: existing.foodCode,
            externalId: existing.externalId,
            source: existing.source,
            confidenceScore: existing.confidenceScore,
            templateId: existing.templateId,
            createdAt: existing.createdAt,
            modifiedAt: DateTime.now(),
            originalValues: existing.originalValues,
            parentEntryId: existing.parentEntryId,
            preparationDetails: preparationDetails,
            componentFoods: components,
            componentSnapshots: snapshots,
          );
    for (final composition in meal.componentFoods!) {
      composition.parentEntryId = meal.id;
    }
    return meal;
  }

  Future<void> _saveMeal() async {
    Offset? saveSource;
    final saveContext = _saveButtonKey.currentContext;
    if (widget.existingMeal == null && saveContext != null) {
      saveSource = globalCenter(saveContext);
    }
    final meal = _buildMeal();
    if (meal != null) {
      if (widget.existingMeal == null) {
        final appState = Provider.of<AppState>(context, listen: false);
        try {
          final viewModel =
              widget.templateViewModel ??
              Provider.of<TemplateViewModel?>(context, listen: false) ??
              TemplateViewModel(
                userId: appState.activeSubject?.id ?? 'anonymous',
              );
          meal.templateId = await viewModel.saveFoodAsTemplate(
            name: meal.name,
            food: meal,
          );
        } catch (error, stackTrace) {
          StudyULogger.error(
            'Failed to save meal to My items: $error\n$stackTrace',
          );
          if (mounted) {
            final l10n = AppLocalizations.of(context)!;
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(l10n.could_not_save_results)),
            );
          }
          return;
        }
      }
      if (mounted) {
        final onSavedToSelection =
            widget.existingMeal == null && widget.onSavedToSelection != null
            ? () => widget.onSavedToSelection!(meal, saveSource)
            : null;
        _pop(meal, onSavedToSelection);
      }
    } else if (_foods.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please add at least one food')),
      );
    }
  }

  void _pop([FoodEntry? result, VoidCallback? afterPop]) {
    setState(() => _allowPop = true);
    final route = ModalRoute.of(context);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      Navigator.of(context).pop(result);
      if (afterPop == null) return;
      final completed = route?.completed;
      if (completed == null) {
        WidgetsBinding.instance.addPostFrameCallback((_) => afterPop());
      } else {
        completed.then((_) => afterPop());
      }
    });
  }

  Future<void> _confirmDiscard() async {
    final l10n = AppLocalizations.of(context)!;
    final action = await showUnsavedChangesDialog(
      context,
      title: l10n.unsaved_changes_title,
      message: l10n.unsaved_changes_message,
      discardLabel: l10n.discard_changes,
      continueLabel: l10n.continue_editing,
    );
    if (!mounted) return;

    switch (action) {
      case UnsavedChangesAction.discard:
        _pop();
      case null:
        return;
    }
  }

  String get _snapshot => jsonEncode({
    'name': _nameController.text,
    'description': _descriptionController.text,
    'servings': _servingsController.text,
    'rawWeight': _rawWeightController.text,
    'cookedWeight': _cookedWeightController.text,
    'preparationMethod': _preparationMethodController.text,
    'quickName': _quickNameController.text,
    'quickAmount': _quickAmountController.text,
    'quickCalories': _quickCaloriesController.text,
    'foodIds': [for (final food in _componentFoods) food.id],
    'compositions': [
      for (final food in _foods)
        {
          'id': food.id,
          'foodId': food.foodId,
          'amount': food.amount,
          'unit': food.unit,
          'sortOrder': food.sortOrder,
        },
    ],
  });

  bool get _hasUnsavedChanges => _snapshot != _initialSnapshot;

  Future<void> _saveAsTemplate() async {
    final meal = _buildMeal();
    if (meal == null) {
      if (_foods.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please add at least one food')),
        );
      }
      return;
    }

    final l10n = AppLocalizations.of(context)!;
    final appState = Provider.of<AppState>(context, listen: false);
    final userId = appState.activeSubject?.id ?? 'anonymous';

    final result = await SaveTemplateDialog.show(
      context,
      initialName: _nameController.text,
      templateType: TemplateType.meal,
    );

    if (result != null && mounted) {
      try {
        final viewModel =
            widget.templateViewModel ??
            Provider.of<TemplateViewModel?>(context, listen: false) ??
            TemplateViewModel(userId: userId);
        await viewModel.saveFoodAsTemplate(
          name: result.name,
          food: meal,
          tags: result.tags,
        );
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(l10n.template_saved)));
        }
      } catch (error, stackTrace) {
        StudyULogger.error('Failed to save meal template: $error\n$stackTrace');
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(l10n.could_not_save_results)));
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    if (_foods.isNotEmpty && _cachedNutrition == null) {
      _cachedNutrition = _calculateTotalNutrition();
    }
    final nutrition = _cachedNutrition;

    final l10n = AppLocalizations.of(context)!;
    final canSave = _nameController.text.isNotEmpty && _foods.isNotEmpty;
    final servingsCount = (double.tryParse(_servingsController.text) ?? 1)
        .toInt();

    final scaffold = Scaffold(
      appBar: AppBar(
        title: Text(
          widget.existingMeal == null ? l10n.create_meal : l10n.edit_meal_title,
        ),
        actions: [
          if (_foods.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.bookmark_add_outlined),
              tooltip: l10n.save_meal,
              onPressed: _saveAsTemplate,
            ),
        ],
      ),
      floatingActionButton: canSave
          ? FloatingActionButton.extended(
              key: _saveButtonKey,
              onPressed: _saveMeal,
              backgroundColor: theme.colorScheme.primary,
              foregroundColor: theme.colorScheme.onPrimary,
              icon: const Icon(Icons.check),
              label: Text(l10n.save),
            )
          : null,
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            if (widget.showCurrentMealOnlyNotice &&
                widget.existingMeal != null) ...[
              Card(
                color: theme.colorScheme.secondaryContainer,
                child: ListTile(
                  leading: Icon(
                    Icons.info_outline,
                    color: theme.colorScheme.onSecondaryContainer,
                  ),
                  title: Text(
                    l10n.current_meal_only_banner,
                    style: TextStyle(
                      color: theme.colorScheme.onSecondaryContainer,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
            ],

            // ========== MEAL DETAILS ==========
            _MealInfoCard(
              nameController: _nameController,
              descriptionController: _descriptionController,
              servingsController: _servingsController,
              theme: theme,
              l10n: l10n,
            ),

            if (widget.onCurrentDayPropagationChanged != null) ...[
              Text(
                l10n.food_definition_edit_helper,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 12),
            ],

            if (widget.showCurrentDayPropagationOption)
              CheckboxListTile(
                value: _updateCurrentDayEntries,
                contentPadding: EdgeInsets.zero,
                title: Text(l10n.update_current_day_entries),
                controlAffinity: ListTileControlAffinity.leading,
                onChanged: (value) {
                  final selected = value ?? false;
                  setState(() => _updateCurrentDayEntries = selected);
                  widget.onCurrentDayPropagationChanged?.call(selected);
                },
              ),

            const SizedBox(height: 12),

            // ========== METADATA (Collapsible) ==========
            _PreparationDetailsCard(
              rawWeightController: _rawWeightController,
              cookedWeightController: _cookedWeightController,
              preparationMethodController: _preparationMethodController,
            ),

            const SizedBox(height: 16),

            // ========== FOODS SECTION ==========
            _FoodsSectionHeader(
              foodCount: _foods.length,
              theme: theme,
              onAddFood: _addFood,
              onToggleQuickAdd: () =>
                  setState(() => _showQuickAdd = !_showQuickAdd),
              showQuickAdd: _showQuickAdd,
            ),

            // ========== QUICK ADD FORM ==========
            if (_showQuickAdd) ...[
              const SizedBox(height: 12),
              _QuickAddForm(
                nameController: _quickNameController,
                amountController: _quickAmountController,
                caloriesController: _quickCaloriesController,
                onAdd: _quickAddFood,
                theme: theme,
              ),
            ],

            const SizedBox(height: 12),

            // ========== FOODS LIST ==========
            if (_foods.isEmpty)
              _EmptyFoodsState(theme: theme)
            else
              ...List.generate(_foods.length, (index) {
                final food = _componentFoods[index];
                final composition = _foods[index];

                return _FoodCard(
                  food: food,
                  composition: composition,
                  theme: theme,
                  onRemove: () => _removeFood(index),
                  onUpdateAmount: (amount, unit) =>
                      _updateFoodAmount(index, amount, unit),
                );
              }),

            const SizedBox(height: 16),

            // ========== NUTRITION SUMMARY ==========
            if (nutrition != null)
              NutritionSummaryCard(
                nutrition: nutrition,
                title: 'Nutrition per Serving',
                subtitle:
                    '$servingsCount ${servingsCount == 1 ? 'serving' : 'servings'}',
              ),

            // Bottom padding for FAB
            const SizedBox(height: 80),
          ],
        ),
      ),
    );

    return PopScope(
      canPop: _allowPop,
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) return;
        if (_hasUnsavedChanges) {
          _confirmDiscard();
        } else {
          _pop();
        }
      },
      child: scaffold,
    );
  }
}

// ============================================================
// WIDGETS
// ============================================================

class _MealInfoCard extends StatelessWidget {
  final TextEditingController nameController;
  final TextEditingController descriptionController;
  final TextEditingController servingsController;
  final ThemeData theme;
  final AppLocalizations l10n;

  const _MealInfoCard({
    required this.nameController,
    required this.descriptionController,
    required this.servingsController,
    required this.theme,
    required this.l10n,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primaryContainer.withValues(
                      alpha: 0.5,
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.restaurant_menu_outlined,
                    size: 20,
                    color: theme.colorScheme.primary,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  l10n.meal_details,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: 'Meal Name *',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.edit),
              ),
              textCapitalization: TextCapitalization.words,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a meal name';
                }
                return null;
              },
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: servingsController,
                    decoration: const InputDecoration(
                      labelText: 'Servings *',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.people_outline),
                    ),
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(
                        RegExp(r'^\d+\.?\d{0,2}'),
                      ),
                    ],
                    validator: (value) {
                      final servings = double.tryParse(value ?? '');
                      if (servings == null || servings <= 0) return 'Required';
                      return null;
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 2,
                  child: TextFormField(
                    controller: descriptionController,
                    decoration: const InputDecoration(
                      labelText: 'Description',
                      border: OutlineInputBorder(),
                      hintText: 'Optional',
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _PreparationDetailsCard extends StatelessWidget {
  final TextEditingController rawWeightController;
  final TextEditingController cookedWeightController;
  final TextEditingController preparationMethodController;

  const _PreparationDetailsCard({
    required this.rawWeightController,
    required this.cookedWeightController,
    required this.preparationMethodController,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      clipBehavior: Clip.antiAlias,
      child: ExpansionTile(
        leading: Icon(Icons.science_outlined, color: Colors.grey.shade600),
        title: const Text('Preparation details'),
        subtitle: const Text('Raw/cooked weights, preparation method'),
        childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        children: [
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: rawWeightController,
                  decoration: const InputDecoration(
                    labelText: 'Raw Weight (g)',
                    border: OutlineInputBorder(),
                    isDense: true,
                  ),
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(
                      RegExp(r'^\d+\.?\d{0,2}'),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: TextFormField(
                  controller: cookedWeightController,
                  decoration: const InputDecoration(
                    labelText: 'Cooked Weight (g)',
                    border: OutlineInputBorder(),
                    isDense: true,
                  ),
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(
                      RegExp(r'^\d+\.?\d{0,2}'),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: preparationMethodController,
            decoration: const InputDecoration(
              labelText: 'Preparation details',
              border: OutlineInputBorder(),
              hintText: 'e.g., baked, fried, steamed',
              isDense: true,
            ),
          ),
        ],
      ),
    );
  }
}

class _FoodsSectionHeader extends StatelessWidget {
  final int foodCount;
  final ThemeData theme;
  final VoidCallback onAddFood;
  final VoidCallback onToggleQuickAdd;
  final bool showQuickAdd;

  const _FoodsSectionHeader({
    required this.foodCount,
    required this.theme,
    required this.onAddFood,
    required this.onToggleQuickAdd,
    required this.showQuickAdd,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'Foods ($foodCount)',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        Row(
          children: [
            IconButton.outlined(
              onPressed: onToggleQuickAdd,
              icon: Icon(showQuickAdd ? Icons.close : Icons.bolt, size: 18),
              tooltip: 'Add food manually',
              style: IconButton.styleFrom(
                minimumSize: const Size(36, 36),
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
            ),
            const SizedBox(width: 8),
            FilledButton(
              onPressed: onAddFood,
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.search, size: 18),
                  SizedBox(width: 6),
                  Text('Add food'),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _QuickAddForm extends StatefulWidget {
  final TextEditingController nameController;
  final TextEditingController amountController;
  final TextEditingController caloriesController;
  final VoidCallback onAdd;
  final ThemeData theme;

  const _QuickAddForm({
    required this.nameController,
    required this.amountController,
    required this.caloriesController,
    required this.onAdd,
    required this.theme,
  });

  @override
  State<_QuickAddForm> createState() => _QuickAddFormState();
}

class _QuickAddFormState extends State<_QuickAddForm> {
  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.bolt,
                  color: widget.theme.colorScheme.tertiary,
                  size: 16,
                ),
                const SizedBox(width: 6),
                Text(
                  'Add food manually',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: widget.theme.colorScheme.tertiary,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            // Name field - full width
            TextField(
              controller: widget.nameController,
              decoration: const InputDecoration(
                labelText: 'Name *',
                hintText: 'e.g., Olive oil',
                border: OutlineInputBorder(),
                isDense: true,
              ),
              textCapitalization: TextCapitalization.words,
              onSubmitted: (_) => _submitAndFocusNext(),
            ),
            const SizedBox(height: 8),
            // Amount and Calories - side by side
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: widget.amountController,
                    decoration: const InputDecoration(
                      labelText: 'Qty',
                      border: OutlineInputBorder(),
                      isDense: true,
                    ),
                    keyboardType: TextInputType.number,
                    onSubmitted: (_) => _submitAndFocusNext(),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  flex: 2,
                  child: TextField(
                    controller: widget.caloriesController,
                    decoration: const InputDecoration(
                      labelText: 'Calories (kcal)',
                      border: OutlineInputBorder(),
                      isDense: true,
                    ),
                    keyboardType: TextInputType.number,
                    onSubmitted: (_) => widget.onAdd(),
                  ),
                ),
                const SizedBox(width: 8),
                SizedBox(
                  height: 48,
                  child: FilledButton.tonal(
                    onPressed: widget.onAdd,
                    child: const Text('Add'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _submitAndFocusNext() {
    if (widget.caloriesController.text.isEmpty) {
      FocusScope.of(context).nextFocus();
    } else {
      widget.onAdd();
    }
  }
}

class _EmptyFoodsState extends StatelessWidget {
  final ThemeData theme;

  const _EmptyFoodsState({required this.theme});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Icon(
                Icons.restaurant_outlined,
                size: 32,
                color: theme.colorScheme.primary,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'No foods yet',
              style: theme.textTheme.titleMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Search or add food manually to start',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant.withValues(
                  alpha: 0.7,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FoodCard extends StatelessWidget {
  final FoodEntry food;
  final FoodComposition composition;
  final ThemeData theme;
  final VoidCallback onRemove;
  final Function(double amount, String unit) onUpdateAmount;

  const _FoodCard({
    required this.food,
    required this.composition,
    required this.theme,
    required this.onRemove,
    required this.onUpdateAmount,
  });

  @override
  Widget build(BuildContext context) {
    final icon = food.entryType == FoodEntryType.meal
        ? Icons.restaurant_menu_outlined
        : Icons.restaurant_outlined;
    final imageUrl = foodImageUrl(food);

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      elevation: 0,
      child: ListTile(
        leading: SizedBox(
          width: 40,
          height: 40,
          child: imageUrl == null
              ? fallbackFoodIcon(theme, icon)
              : ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Image.network(
                    imageUrl,
                    fit: BoxFit.cover,
                    excludeFromSemantics: true,
                    errorBuilder: (context, error, stackTrace) =>
                        fallbackFoodIcon(theme, icon),
                  ),
                ),
        ),
        title: Text(
          food.name,
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w500,
          ),
        ),
        subtitle: Text(
          '${composition.amount} ${composition.unit} • ${food.nutrition.energyKcal.toStringAsFixed(0)} kcal',
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.edit_outlined, size: 18),
              onPressed: () => _showEditDialog(context),
              tooltip: 'Edit amount',
              visualDensity: VisualDensity.compact,
            ),
            IconButton(
              icon: const Icon(Icons.delete_outline, size: 18),
              onPressed: onRemove,
              color: theme.colorScheme.error,
              tooltip: 'Remove',
              visualDensity: VisualDensity.compact,
            ),
          ],
        ),
      ),
    );
  }

  void _showEditDialog(BuildContext context) {
    final amountController = TextEditingController(
      text: composition.amount.toString(),
    );
    final unitController = TextEditingController(text: composition.unit);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit food'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: amountController,
              decoration: const InputDecoration(
                labelText: 'Amount',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 12),
            TextField(
              controller: unitController,
              decoration: const InputDecoration(
                labelText: 'Unit',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              final amount =
                  double.tryParse(amountController.text) ?? composition.amount;
              onUpdateAmount(amount, unitController.text);
              Navigator.pop(context);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }
}
