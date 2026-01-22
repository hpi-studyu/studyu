import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:studyu_app/l10n/app_localizations.dart';
import 'package:studyu_app/models/app_state.dart';
import 'package:studyu_app/screens/study/nutrition/food_search_screen.dart';
import 'package:studyu_app/screens/study/nutrition/template_view_model.dart';
import 'package:studyu_app/widgets/save_template_dialog.dart';
import 'package:studyu_core/core.dart';

class RecipeBuilderScreen extends StatefulWidget {
  final FoodEntry? existingRecipe;

  const RecipeBuilderScreen({this.existingRecipe, super.key});

  static MaterialPageRoute<FoodEntry> route({FoodEntry? existingRecipe}) =>
      MaterialPageRoute(
        builder: (_) => RecipeBuilderScreen(existingRecipe: existingRecipe),
      );

  @override
  State<RecipeBuilderScreen> createState() => _RecipeBuilderScreenState();
}

class _RecipeBuilderScreenState extends State<RecipeBuilderScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _descriptionController;
  late TextEditingController _servingsController;

  // Recipe metadata controllers
  late TextEditingController _rawWeightController;
  late TextEditingController _cookedWeightController;
  late TextEditingController _preparationMethodController;

  // Quick Add controllers
  late TextEditingController _quickNameController;
  late TextEditingController _quickAmountController;
  late TextEditingController _quickCaloriesController;
  bool _showQuickAdd = false;

  List<RecipeComposition> _ingredients = [];
  final List<FoodEntry> _ingredientFoods = [];
  RecipeMetadata? _metadata;
  NutritionProfile? _cachedNutrition;

  @override
  void initState() {
    super.initState();
    if (widget.existingRecipe != null) {
      final recipe = widget.existingRecipe!;
      _nameController = TextEditingController(text: recipe.name);
      _descriptionController = TextEditingController(
        text: recipe.description ?? '',
      );
      _servingsController = TextEditingController(
        text: recipe.amount.toString(),
      );

      if (recipe.recipeMetadata != null) {
        _metadata = recipe.recipeMetadata;
        _rawWeightController = TextEditingController(
          text: _metadata!.rawWeight.toString(),
        );
        _cookedWeightController = TextEditingController(
          text: _metadata!.cookedWeight.toString(),
        );
        _preparationMethodController = TextEditingController(
          text: _metadata!.preparationMethod,
        );
      } else {
        _rawWeightController = TextEditingController();
        _cookedWeightController = TextEditingController();
        _preparationMethodController = TextEditingController();
      }

      _ingredients = recipe.recipeIngredients ?? [];
    } else {
      _nameController = TextEditingController();
      _descriptionController = TextEditingController();
      _servingsController = TextEditingController(text: '1');
      _rawWeightController = TextEditingController();
      _cookedWeightController = TextEditingController();
      _preparationMethodController = TextEditingController();
    }

    // Initialize Quick Add controllers
    _quickNameController = TextEditingController();
    _quickAmountController = TextEditingController(text: '1');
    _quickCaloriesController = TextEditingController();

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

  Future<void> _addIngredient() async {
    // Use FoodSearchScreen (unified search) instead of FoodEntryScreen
    final result = await Navigator.of(context).push(FoodSearchScreen.route());
    if (result != null) {
      setState(() {
        _ingredientFoods.add(result);
        _ingredients.add(
          RecipeComposition.withId(
            recipeId: '', // Will be set when saving
            ingredientId: result.id,
            amount: result.amount,
            unit: result.unit,
            sortOrder: _ingredients.length,
          ),
        );
        _cachedNutrition = null;
      });
    }
  }

  void _quickAddIngredient() {
    final name = _quickNameController.text.trim();
    final amount = double.tryParse(_quickAmountController.text) ?? 1;
    final calories = double.tryParse(_quickCaloriesController.text) ?? 0;

    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter ingredient name')),
      );
      return;
    }

    // Create a simple manual food entry
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
      _ingredientFoods.add(quickFood);
      _ingredients.add(
        RecipeComposition.withId(
          recipeId: '',
          ingredientId: quickFood.id,
          amount: amount,
          unit: 'serving',
          sortOrder: _ingredients.length,
        ),
      );
      _cachedNutrition = null;

      // Clear quick add fields
      _quickNameController.clear();
      _quickAmountController.text = '1';
      _quickCaloriesController.clear();
      _showQuickAdd = false;
    });
  }

  void _removeIngredient(int index) {
    setState(() {
      _ingredients.removeAt(index);
      _ingredientFoods.removeAt(index);
      _cachedNutrition = null;
    });
  }

  void _updateIngredientAmount(int index, double amount, String unit) {
    setState(() {
      _ingredients[index] = RecipeComposition(
        id: _ingredients[index].id,
        recipeId: _ingredients[index].recipeId,
        ingredientId: _ingredients[index].ingredientId,
        amount: amount,
        unit: unit,
        sortOrder: _ingredients[index].sortOrder,
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

    for (int i = 0; i < _ingredientFoods.length; i++) {
      final food = _ingredientFoods[i];
      final composition = _ingredients[i];

      // Calculate ratio based on amount
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
      micros: totalMicros,
    );
  }

  FoodEntry? _buildRecipe() {
    if (!_formKey.currentState!.validate() || _ingredients.isEmpty) {
      return null;
    }

    final nutrition = _calculateTotalNutrition();

    RecipeMetadata? metadata;
    if (_rawWeightController.text.isNotEmpty &&
        _cookedWeightController.text.isNotEmpty &&
        _preparationMethodController.text.isNotEmpty) {
      final rawWeight = double.parse(_rawWeightController.text);
      final cookedWeight = double.parse(_cookedWeightController.text);
      metadata = RecipeMetadata(
        rawWeight: rawWeight,
        cookedWeight: cookedWeight,
        yieldFactor: cookedWeight / rawWeight,
        preparationMethod: _preparationMethodController.text,
        retentionFactors: {},
      );
    }

    return FoodEntry.withId(
      entryType: FoodEntryType.recipe,
      name: _nameController.text,
      description: _descriptionController.text.isEmpty
          ? null
          : _descriptionController.text,
      amount: double.parse(_servingsController.text),
      unit: 'serving',
      servingSizeGrams: nutrition.energyKcal * 0.24,
      portionEstimationMethod: PortionEstimationMethod.householdMeasure,
      portionState: PortionState.cooked,
      nutrition: nutrition,
      source: FoodSource.manual,
      confidenceScore: 0.9,
      originalValues: {},
      recipeMetadata: metadata,
      recipeIngredients: _ingredients
          .map(
            (comp) => RecipeComposition(
              id: comp.id,
              recipeId: '',
              ingredientId: comp.ingredientId,
              amount: comp.amount,
              unit: comp.unit,
              sortOrder: comp.sortOrder,
            ),
          )
          .toList(),
    );
  }

  void _saveRecipe() {
    final recipe = _buildRecipe();
    if (recipe != null) {
      Navigator.of(context).pop(recipe);
    } else if (_ingredients.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please add at least one ingredient')),
      );
    }
  }

  Future<void> _saveAsTemplate() async {
    final recipe = _buildRecipe();
    if (recipe == null) {
      if (_ingredients.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please add at least one ingredient')),
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
      templateType: TemplateType.recipe,
    );

    if (result != null && mounted) {
      final viewModel = TemplateViewModel(userId: userId);
      await viewModel.saveFoodAsTemplate(
        name: result.name,
        food: recipe,
        tags: result.tags,
      );
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(l10n.template_saved)));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    if (_ingredients.isNotEmpty && _cachedNutrition == null) {
      _cachedNutrition = _calculateTotalNutrition();
    }
    final nutrition = _cachedNutrition;

    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Recipe Builder'),
        actions: [
          if (_ingredients.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.bookmark_add),
              tooltip: l10n.save_as_template,
              onPressed: _saveAsTemplate,
            ),
          TextButton(
            onPressed: _saveRecipe,
            style: TextButton.styleFrom(foregroundColor: Colors.white),
            child: Text(l10n.save),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Recipe Basic Info
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Recipe Information',
                        style: theme.textTheme.titleLarge,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _nameController,
                        decoration: const InputDecoration(
                          labelText: 'Recipe Name *',
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter a recipe name';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _descriptionController,
                        decoration: const InputDecoration(
                          labelText: 'Description',
                          border: OutlineInputBorder(),
                          hintText: 'Describe your recipe',
                        ),
                        maxLines: 3,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _servingsController,
                        decoration: const InputDecoration(
                          labelText: 'Number of Servings *',
                          border: OutlineInputBorder(),
                        ),
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(
                            RegExp(r'^\d+\.?\d{0,2}'),
                          ),
                        ],
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter number of servings';
                          }
                          return null;
                        },
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Recipe Metadata
              Card(
                child: ExpansionTile(
                  title: const Text('Recipe Metadata (Optional)'),
                  leading: const Icon(Icons.science),
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: TextFormField(
                                  controller: _rawWeightController,
                                  decoration: const InputDecoration(
                                    labelText: 'Raw Weight (g)',
                                    border: OutlineInputBorder(),
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
                                  controller: _cookedWeightController,
                                  decoration: const InputDecoration(
                                    labelText: 'Cooked Weight (g)',
                                    border: OutlineInputBorder(),
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
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: _preparationMethodController,
                            decoration: const InputDecoration(
                              labelText: 'Preparation Method',
                              border: OutlineInputBorder(),
                              hintText: 'e.g., baked, fried, steamed',
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Ingredients Section Header
              Text(
                'Ingredients (${_ingredients.length})',
                style: theme.textTheme.titleLarge,
              ),
              const SizedBox(height: 12),

              // Add Ingredient Options
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _addIngredient,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: theme.colorScheme.primary,
                        foregroundColor: theme.colorScheme.onPrimary,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      icon: const Icon(Icons.search),
                      label: const Text('Search & Add'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  OutlinedButton.icon(
                    onPressed: () =>
                        setState(() => _showQuickAdd = !_showQuickAdd),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    icon: Icon(_showQuickAdd ? Icons.close : Icons.bolt),
                    label: Text(_showQuickAdd ? 'Cancel' : 'Quick Add'),
                  ),
                ],
              ),

              // Quick Add Form (collapsible)
              if (_showQuickAdd) ...[
                const SizedBox(height: 12),
                Card(
                  color: Colors.amber.shade50,
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.bolt,
                              color: Colors.amber.shade700,
                              size: 18,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Quick Add Ingredient',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.amber.shade900,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              flex: 3,
                              child: TextField(
                                controller: _quickNameController,
                                decoration: const InputDecoration(
                                  labelText: 'Name *',
                                  hintText: 'e.g., Olive oil',
                                  border: OutlineInputBorder(),
                                  isDense: true,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              flex: 1,
                              child: TextField(
                                controller: _quickAmountController,
                                decoration: const InputDecoration(
                                  labelText: 'Qty',
                                  border: OutlineInputBorder(),
                                  isDense: true,
                                ),
                                keyboardType: TextInputType.number,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              flex: 1,
                              child: TextField(
                                controller: _quickCaloriesController,
                                decoration: const InputDecoration(
                                  labelText: 'kcal',
                                  border: OutlineInputBorder(),
                                  isDense: true,
                                ),
                                keyboardType: TextInputType.number,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: _quickAddIngredient,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.amber.shade700,
                              foregroundColor: Colors.white,
                            ),
                            child: const Text('Add to Recipe'),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],

              const SizedBox(height: 16),

              if (_ingredients.isEmpty)
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(32),
                    child: Center(
                      child: Column(
                        children: [
                          Icon(
                            Icons.restaurant_menu,
                            size: 48,
                            color: theme.colorScheme.primary.withValues(
                              alpha: 0.5,
                            ),
                          ),
                          const SizedBox(height: 8),
                          const Text('No ingredients added yet'),
                          const SizedBox(height: 4),
                          Text(
                            'Use "Search & Add" or "Quick Add" above',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                )
              else
                ...List.generate(_ingredients.length, (index) {
                  final ingredient = _ingredientFoods[index];
                  final composition = _ingredients[index];

                  return Card(
                    margin: const EdgeInsets.only(bottom: 8),
                    child: ExpansionTile(
                      leading: const Icon(Icons.restaurant),
                      title: Text(ingredient.name),
                      subtitle: Text(
                        '${composition.amount} ${composition.unit} • ${ingredient.nutrition.energyKcal.toStringAsFixed(0)} kcal',
                      ),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () => _removeIngredient(index),
                      ),
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(16),
                          child: Row(
                            children: [
                              Expanded(
                                child: TextFormField(
                                  initialValue: composition.amount.toString(),
                                  decoration: const InputDecoration(
                                    labelText: 'Amount',
                                    border: OutlineInputBorder(),
                                  ),
                                  keyboardType: TextInputType.number,
                                  onChanged: (value) {
                                    final amount =
                                        double.tryParse(value) ??
                                        composition.amount;
                                    _updateIngredientAmount(
                                      index,
                                      amount,
                                      composition.unit,
                                    );
                                  },
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: TextFormField(
                                  initialValue: composition.unit,
                                  decoration: const InputDecoration(
                                    labelText: 'Unit',
                                    border: OutlineInputBorder(),
                                  ),
                                  onChanged: (value) {
                                    _updateIngredientAmount(
                                      index,
                                      composition.amount,
                                      value,
                                    );
                                  },
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                }),

              const SizedBox(height: 24),

              // Nutrition Summary
              if (nutrition != null)
                Card(
                  color: theme.colorScheme.primaryContainer,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Nutrition per Serving',
                          style: theme.textTheme.titleLarge?.copyWith(
                            color: theme.colorScheme.onPrimaryContainer,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Wrap(
                          spacing: 16,
                          runSpacing: 12,
                          children: [
                            _NutritionChip(
                              label: 'Calories',
                              value:
                                  '${nutrition.energyKcal.toStringAsFixed(0)} kcal',
                              icon: Icons.local_fire_department,
                            ),
                            _NutritionChip(
                              label: 'Protein',
                              value: '${nutrition.protein.toStringAsFixed(1)}g',
                              icon: Icons.egg,
                            ),
                            _NutritionChip(
                              label: 'Carbs',
                              value: '${nutrition.carbs.toStringAsFixed(1)}g',
                              icon: Icons.bakery_dining,
                            ),
                            _NutritionChip(
                              label: 'Fat',
                              value: '${nutrition.fat.toStringAsFixed(1)}g',
                              icon: Icons.opacity,
                            ),
                            _NutritionChip(
                              label: 'Fiber',
                              value: '${nutrition.fiber.toStringAsFixed(1)}g',
                              icon: Icons.grass,
                            ),
                            _NutritionChip(
                              label: 'Sugar',
                              value: '${nutrition.sugars.toStringAsFixed(1)}g',
                              icon: Icons.icecream,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NutritionChip extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;

  const _NutritionChip({
    required this.label,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Chip(avatar: Icon(icon, size: 18), label: Text('$label: $value'));
  }
}
