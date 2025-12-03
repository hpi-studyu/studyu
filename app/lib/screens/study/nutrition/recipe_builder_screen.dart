import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:studyu_app/screens/study/nutrition/food_entry_screen.dart';
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

  List<RecipeComposition> _ingredients = [];
  final List<FoodEntry> _ingredientFoods = [];
  RecipeMetadata? _metadata;

  @override
  void initState() {
    super.initState();
    if (widget.existingRecipe != null) {
      final recipe = widget.existingRecipe!;
      _nameController = TextEditingController(text: recipe.name);
      _descriptionController = TextEditingController(text: recipe.description ?? '');
      _servingsController = TextEditingController(text: recipe.amount.toString());
      
      if (recipe.recipeMetadata != null) {
        _metadata = recipe.recipeMetadata;
        _rawWeightController = TextEditingController(text: _metadata!.rawWeight.toString());
        _cookedWeightController = TextEditingController(text: _metadata!.cookedWeight.toString());
        _preparationMethodController = TextEditingController(text: _metadata!.preparationMethod);
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
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _servingsController.dispose();
    _rawWeightController.dispose();
    _cookedWeightController.dispose();
    _preparationMethodController.dispose();
    super.dispose();
  }

  Future<void> _addIngredient() async {
    final result = await Navigator.of(context).push(
      FoodEntryScreen.route(),
    );
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
      });
    }
  }

  void _removeIngredient(int index) {
    setState(() {
      _ingredients.removeAt(index);
      _ingredientFoods.removeAt(index);
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

  void _saveRecipe() {
    if (_formKey.currentState!.validate() && _ingredients.isNotEmpty) {
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

      final recipe = FoodEntry.withId(
        entryType: FoodEntryType.recipe,
        name: _nameController.text,
        description: _descriptionController.text.isEmpty ? null : _descriptionController.text,
        amount: double.parse(_servingsController.text),
        unit: 'serving',
        servingSizeGrams: nutrition.energyKcal * 0.24, // Rough estimate
        portionEstimationMethod: PortionEstimationMethod.householdMeasure,
        portionState: PortionState.cooked,
        nutrition: nutrition,
        source: FoodSource.manual,
        confidenceScore: 0.9,
        originalValues: {},
        recipeMetadata: metadata,
        recipeIngredients: _ingredients.map((comp) => RecipeComposition(
          id: comp.id,
          recipeId: '', // Will be populated
          ingredientId: comp.ingredientId,
          amount: comp.amount,
          unit: comp.unit,
          sortOrder: comp.sortOrder,
        )).toList(),
      );

      Navigator.of(context).pop(recipe);
    } else if (_ingredients.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please add at least one ingredient')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final nutrition = _ingredients.isNotEmpty ? _calculateTotalNutrition() : null;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Recipe Builder'),
        actions: [
          TextButton(
            onPressed: _saveRecipe,
            style: TextButton.styleFrom(
              foregroundColor: Colors.white,
            ),
            child: const Text('SAVE'),
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
                      Text('Recipe Information', style: theme.textTheme.titleLarge),
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
                          FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
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
                                    FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
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
                                    FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
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

              // Ingredients Section
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Ingredients (${_ingredients.length})', style: theme.textTheme.titleLarge),
                  ElevatedButton.icon(
                    onPressed: _addIngredient,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: theme.colorScheme.primary,
                      foregroundColor: theme.colorScheme.onPrimary,
                    ),
                    icon: const Icon(Icons.add),
                    label: const Text('Add Ingredient'),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              if (_ingredients.isEmpty)
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
                          const Text('No ingredients added yet'),
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
                                    final amount = double.tryParse(value) ?? composition.amount;
                                    _updateIngredientAmount(index, amount, composition.unit);
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
                                    _updateIngredientAmount(index, composition.amount, value);
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
                              value: '${nutrition.energyKcal.toStringAsFixed(0)} kcal',
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
    return Chip(
      avatar: Icon(icon, size: 18),
      label: Text('$label: $value'),
    );
  }
}

