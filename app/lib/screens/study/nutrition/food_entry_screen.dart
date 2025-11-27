import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:studyu_core/core.dart';

class FoodEntryScreen extends StatefulWidget {
  final FoodEntry? existingFood;

  const FoodEntryScreen({this.existingFood, super.key});

  static MaterialPageRoute<FoodEntry> route({FoodEntry? existingFood}) =>
      MaterialPageRoute(
        builder: (_) => FoodEntryScreen(existingFood: existingFood),
      );

  @override
  State<FoodEntryScreen> createState() => _FoodEntryScreenState();
}

class _FoodEntryScreenState extends State<FoodEntryScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _brandController;
  late TextEditingController _descriptionController;
  late TextEditingController _amountController;
  late TextEditingController _unitController;
  late TextEditingController _servingSizeController;
  late TextEditingController _portionReferenceController;
  late TextEditingController _yieldFactorController;
  late TextEditingController _ediblePortionController;

  // Nutrition controllers
  late TextEditingController _energyController;
  late TextEditingController _proteinController;
  late TextEditingController _carbsController;
  late TextEditingController _fatController;
  late TextEditingController _sugarsController;
  late TextEditingController _fiberController;
  late TextEditingController _saturatedFatController;
  late TextEditingController _sodiumController;

  FoodEntryType _entryType = FoodEntryType.singleIngredient;
  PortionEstimationMethod _portionMethod =
      PortionEstimationMethod.householdMeasure;
  PortionState _portionState = PortionState.asServed;
  FoodSource _source = FoodSource.manual;

  @override
  void initState() {
    super.initState();
    if (widget.existingFood != null) {
      final food = widget.existingFood!;
      _nameController = TextEditingController(text: food.name);
      _brandController = TextEditingController(text: food.brandName ?? '');
      _descriptionController = TextEditingController(
        text: food.description ?? '',
      );
      _amountController = TextEditingController(text: food.amount.toString());
      _unitController = TextEditingController(text: food.unit);
      _servingSizeController = TextEditingController(
        text: food.servingSizeGrams.toString(),
      );
      _portionReferenceController = TextEditingController(
        text: food.portionReference ?? '',
      );
      _yieldFactorController = TextEditingController(
        text: food.yieldFactor?.toString() ?? '',
      );
      _ediblePortionController = TextEditingController(
        text: food.ediblePortion?.toString() ?? '',
      );

      _energyController = TextEditingController(
        text: food.nutrition.energyKcal.toString(),
      );
      _proteinController = TextEditingController(
        text: food.nutrition.protein.toString(),
      );
      _carbsController = TextEditingController(
        text: food.nutrition.carbs.toString(),
      );
      _fatController = TextEditingController(
        text: food.nutrition.fat.toString(),
      );
      _sugarsController = TextEditingController(
        text: food.nutrition.sugars.toString(),
      );
      _fiberController = TextEditingController(
        text: food.nutrition.fiber.toString(),
      );
      _saturatedFatController = TextEditingController(
        text: food.nutrition.saturatedFat.toString(),
      );
      _sodiumController = TextEditingController(
        text: food.nutrition.sodium.toString(),
      );

      _entryType = food.entryType;
      _portionMethod = food.portionEstimationMethod;
      _portionState = food.portionState;
      _source = food.source;
    } else {
      _nameController = TextEditingController();
      _brandController = TextEditingController();
      _descriptionController = TextEditingController();
      _amountController = TextEditingController(text: '1');
      _unitController = TextEditingController(text: 'serving');
      _servingSizeController = TextEditingController(text: '100');
      _portionReferenceController = TextEditingController();
      _yieldFactorController = TextEditingController();
      _ediblePortionController = TextEditingController();

      _energyController = TextEditingController();
      _proteinController = TextEditingController();
      _carbsController = TextEditingController();
      _fatController = TextEditingController();
      _sugarsController = TextEditingController();
      _fiberController = TextEditingController();
      _saturatedFatController = TextEditingController();
      _sodiumController = TextEditingController();
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _brandController.dispose();
    _descriptionController.dispose();
    _amountController.dispose();
    _unitController.dispose();
    _servingSizeController.dispose();
    _portionReferenceController.dispose();
    _yieldFactorController.dispose();
    _ediblePortionController.dispose();
    _energyController.dispose();
    _proteinController.dispose();
    _carbsController.dispose();
    _fatController.dispose();
    _sugarsController.dispose();
    _fiberController.dispose();
    _saturatedFatController.dispose();
    _sodiumController.dispose();
    super.dispose();
  }

  void _saveFood() {
    if (_formKey.currentState!.validate()) {
      final nutrition = NutritionProfile(
        energyKcal: double.tryParse(_energyController.text) ?? 0,
        protein: double.tryParse(_proteinController.text) ?? 0,
        carbs: double.tryParse(_carbsController.text) ?? 0,
        fat: double.tryParse(_fatController.text) ?? 0,
        sugars: double.tryParse(_sugarsController.text) ?? 0,
        fiber: double.tryParse(_fiberController.text) ?? 0,
        saturatedFat: double.tryParse(_saturatedFatController.text) ?? 0,
        transFat: 0,
        cholesterol: 0,
        sodium: double.tryParse(_sodiumController.text) ?? 0,
        waterContent: 0,
        micros: {},
      );

      final food = FoodEntry.withId(
        entryType: _entryType,
        name: _nameController.text,
        brandName: _brandController.text.isEmpty ? null : _brandController.text,
        description: _descriptionController.text.isEmpty
            ? null
            : _descriptionController.text,
        amount: double.parse(_amountController.text),
        unit: _unitController.text,
        servingSizeGrams: double.parse(_servingSizeController.text),
        portionReference: _portionReferenceController.text.isEmpty
            ? null
            : _portionReferenceController.text,
        portionEstimationMethod: _portionMethod,
        portionState: _portionState,
        yieldFactor: _yieldFactorController.text.isEmpty
            ? null
            : double.tryParse(_yieldFactorController.text),
        ediblePortion: _ediblePortionController.text.isEmpty
            ? null
            : double.tryParse(_ediblePortionController.text),
        nutrition: nutrition,
        source: _source,
        confidenceScore: 1.0,
        originalValues: {},
      );

      Navigator.of(context).pop(food);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text(widget.existingFood != null ? 'Edit Food' : 'Add Food'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Search'),
              Tab(text: 'Manual Entry'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: _saveFood,
              style: TextButton.styleFrom(
                foregroundColor: theme.colorScheme.primary,
                textStyle: const TextStyle(fontWeight: FontWeight.bold),
              ),
              child: const Text('SAVE'),
            ),
          ],
        ),
        body: TabBarView(
          children: [_buildSearchTab(theme), _buildManualEntryTab(theme)],
        ),
      ),
    );
  }

  Widget _buildSearchTab(ThemeData theme) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: TextField(
            decoration: InputDecoration(
              hintText: 'Search for food (e.g. "Apple")',
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              filled: true,
              fillColor: theme.colorScheme.surfaceContainer,
            ),
          ),
        ),
        Expanded(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.search_off,
                  size: 64,
                  color: theme.colorScheme.outline,
                ),
                const SizedBox(height: 16),
                Text(
                  'Search is coming soon',
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Please use Manual Entry for now',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildManualEntryTab(ThemeData theme) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Food Info Section
            Text('Food Info', style: theme.textTheme.titleMedium),
            const SizedBox(height: 16),
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Food Name',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.restaurant),
              ),
              validator: (value) =>
                  value == null || value.isEmpty ? 'Please enter a name' : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _brandController,
              decoration: const InputDecoration(
                labelText: 'Brand (Optional)',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.branding_watermark),
              ),
            ),
            const SizedBox(height: 24),

            // Portion Section
            Text('Portion', style: theme.textTheme.titleMedium),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  flex: 2,
                  child: TextFormField(
                    controller: _amountController,
                    decoration: const InputDecoration(
                      labelText: 'Amount',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
                    ],
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Required';
                      }
                      if (double.tryParse(value) == null) {
                        return 'Invalid number';
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  flex: 3,
                  child: TextFormField(
                    controller: _unitController,
                    decoration: const InputDecoration(
                      labelText: 'Unit (e.g. g, ml, slice)',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) =>
                        value == null || value.isEmpty ? 'Required' : null,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Nutrition Section
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Nutrition Facts', style: theme.textTheme.titleMedium),
                Text(
                  'per 100g/ml',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Main Nutrients Grid
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              childAspectRatio: 2.5,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              children: [
                _buildNutrientInput('Calories', 'kcal', _energyController),
                _buildNutrientInput('Protein', 'g', _proteinController),
                _buildNutrientInput('Carbs', 'g', _carbsController),
                _buildNutrientInput('Fat', 'g', _fatController),
              ],
            ),

            const SizedBox(height: 16),
            ExpansionTile(
              title: const Text('Detailed Nutrition'),
              tilePadding: EdgeInsets.zero,
              children: [
                _buildNutrientInput('Fiber', 'g', _fiberController),
                const SizedBox(height: 12),
                _buildNutrientInput('Sugars', 'g', _sugarsController),
                const SizedBox(height: 12),
                _buildNutrientInput(
                  'Saturated Fat',
                  'g',
                  _saturatedFatController,
                ),
                const SizedBox(height: 12),
                _buildNutrientInput('Sodium', 'mg', _sodiumController),
              ],
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildNutrientInput(
    String label,
    String suffix,
    TextEditingController controller,
  ) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        suffixText: suffix,
        border: const OutlineInputBorder(),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      ),
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      inputFormatters: [
        FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
      ],
      validator: (value) {
        if (value == null || value.isEmpty) {
          return null; // Allow empty, will default to 0
        }
        if (double.tryParse(value) == null) {
          return 'Invalid';
        }
        return null;
      },
    );
  }
}
