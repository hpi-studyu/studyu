import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:studyu_app/screens/study/nutrition/recipe_builder_screen.dart';
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

  String _getEntryTypeLabel(FoodEntryType type) {
    switch (type) {
      case FoodEntryType.singleIngredient:
        return '🥕 Single Ingredient';
      case FoodEntryType.recipe:
        return '📖 Recipe';
      case FoodEntryType.brandedProduct:
        return '🏷️ Branded Product';
      case FoodEntryType.manualCustom:
        return '✏️ Manual Entry';
    }
  }

  String _getPortionMethodLabel(PortionEstimationMethod method) {
    switch (method) {
      case PortionEstimationMethod.householdMeasure:
        return 'Household Measure';
      case PortionEstimationMethod.photograph:
        return 'Photograph';
      case PortionEstimationMethod.standardUnit:
        return 'Standard Unit';
      case PortionEstimationMethod.userWeighted:
        return 'User Weighted';
      case PortionEstimationMethod.unknown:
        return 'Unknown';
    }
  }

  String _getPortionStateLabel(PortionState state) {
    switch (state) {
      case PortionState.raw:
        return 'Raw';
      case PortionState.cooked:
        return 'Cooked';
      case PortionState.asServed:
        return 'As Served';
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Food Entry'),
        actions: [
          TextButton(
            onPressed: _saveFood,
            style: TextButton.styleFrom(foregroundColor: Colors.white),
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
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Food Information',
                        style: theme.textTheme.titleLarge,
                      ),
                      const SizedBox(height: 16),
                      DropdownButtonFormField<FoodEntryType>(
                        initialValue: _entryType,
                        decoration: const InputDecoration(
                          labelText: 'Entry Type',
                          border: OutlineInputBorder(),
                        ),
                        items: FoodEntryType.values.map((type) {
                          return DropdownMenuItem(
                            value: type,
                            child: Text(_getEntryTypeLabel(type)),
                          );
                        }).toList(),
                        onChanged: (value) {
                          if (value != null) {
                            setState(() => _entryType = value);
                          }
                        },
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _nameController,
                        decoration: const InputDecoration(
                          labelText: 'Food Name *',
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter a food name';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      if (_entryType == FoodEntryType.brandedProduct) ...[
                        TextFormField(
                          controller: _brandController,
                          decoration: const InputDecoration(
                            labelText: 'Brand Name',
                            border: OutlineInputBorder(),
                          ),
                        ),
                        const SizedBox(height: 16),
                      ],
                      TextFormField(
                        controller: _descriptionController,
                        decoration: const InputDecoration(
                          labelText: 'Description',
                          border: OutlineInputBorder(),
                          hintText: 'Optional notes about this food',
                        ),
                        maxLines: 2,
                      ),
                      const SizedBox(height: 16),
                      if (_entryType == FoodEntryType.recipe) ...[
                        Card(
                          color: Colors.blue.shade50,
                          child: Padding(
                            padding: const EdgeInsets.all(12),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Icon(
                                      Icons.info_outline,
                                      color: Colors.blue.shade700,
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        'Recipe: Use Recipe Builder for better ingredient management',
                                        style: TextStyle(
                                          color: Colors.blue.shade700,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                ElevatedButton.icon(
                                  onPressed: () async {
                                    final result = await Navigator.of(context)
                                        .push(
                                          RecipeBuilderScreen.route(
                                            existingRecipe: widget.existingFood,
                                          ),
                                        );
                                    if (result != null) {
                                      Navigator.of(context).pop(result);
                                    }
                                  },
                                  icon: const Icon(Icons.menu_book),
                                  label: const Text('Open Recipe Builder'),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                      ],
                      Row(
                        children: [
                          Expanded(
                            flex: 2,
                            child: TextFormField(
                              controller: _amountController,
                              decoration: const InputDecoration(
                                labelText: 'Amount *',
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
                                  return 'Required';
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
                                labelText: 'Unit *',
                                border: OutlineInputBorder(),
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Required';
                                }
                                return null;
                              },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _servingSizeController,
                        decoration: const InputDecoration(
                          labelText: 'Serving Size (grams) *',
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
                            return 'Please enter serving size';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _portionReferenceController,
                        decoration: const InputDecoration(
                          labelText: 'Portion Reference',
                          border: OutlineInputBorder(),
                          hintText: 'e.g., 1 cup, 3 oz, medium apple',
                        ),
                      ),
                      const SizedBox(height: 16),
                      DropdownButtonFormField<PortionEstimationMethod>(
                        initialValue: _portionMethod,
                        decoration: const InputDecoration(
                          labelText: 'Portion Estimation Method',
                          border: OutlineInputBorder(),
                        ),
                        items: PortionEstimationMethod.values.map((method) {
                          return DropdownMenuItem(
                            value: method,
                            child: Text(_getPortionMethodLabel(method)),
                          );
                        }).toList(),
                        onChanged: (value) {
                          if (value != null) {
                            setState(() => _portionMethod = value);
                          }
                        },
                      ),
                      const SizedBox(height: 16),
                      DropdownButtonFormField<PortionState>(
                        initialValue: _portionState,
                        decoration: const InputDecoration(
                          labelText: 'Portion State',
                          border: OutlineInputBorder(),
                        ),
                        items: PortionState.values.map((state) {
                          return DropdownMenuItem(
                            value: state,
                            child: Text(_getPortionStateLabel(state)),
                          );
                        }).toList(),
                        onChanged: (value) {
                          if (value != null) {
                            setState(() => _portionState = value);
                          }
                        },
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _yieldFactorController,
                              decoration: const InputDecoration(
                                labelText: 'Yield Factor',
                                border: OutlineInputBorder(),
                                hintText: 'e.g., 0.75',
                              ),
                              keyboardType: TextInputType.number,
                              inputFormatters: [
                                FilteringTextInputFormatter.allow(
                                  RegExp(r'^\d+\.?\d{0,4}'),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: TextFormField(
                              controller: _ediblePortionController,
                              decoration: const InputDecoration(
                                labelText: 'Edible Portion',
                                border: OutlineInputBorder(),
                                hintText: 'e.g., 0.85',
                              ),
                              keyboardType: TextInputType.number,
                              inputFormatters: [
                                FilteringTextInputFormatter.allow(
                                  RegExp(r'^\d+\.?\d{0,4}'),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Nutrition Information',
                        style: theme.textTheme.titleLarge,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _energyController,
                        decoration: const InputDecoration(
                          labelText: 'Energy (kcal) *',
                          border: OutlineInputBorder(),
                          hintText: '0',
                        ),
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(
                            RegExp(r'^\d+\.?\d{0,2}'),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _proteinController,
                              decoration: const InputDecoration(
                                labelText: 'Protein (g)',
                                border: OutlineInputBorder(),
                                hintText: '0',
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
                              controller: _carbsController,
                              decoration: const InputDecoration(
                                labelText: 'Carbs (g)',
                                border: OutlineInputBorder(),
                                hintText: '0',
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
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _fatController,
                              decoration: const InputDecoration(
                                labelText: 'Fat (g)',
                                border: OutlineInputBorder(),
                                hintText: '0',
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
                              controller: _saturatedFatController,
                              decoration: const InputDecoration(
                                labelText: 'Sat. Fat (g)',
                                border: OutlineInputBorder(),
                                hintText: '0',
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
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _sugarsController,
                              decoration: const InputDecoration(
                                labelText: 'Sugars (g)',
                                border: OutlineInputBorder(),
                                hintText: '0',
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
                              controller: _fiberController,
                              decoration: const InputDecoration(
                                labelText: 'Fiber (g)',
                                border: OutlineInputBorder(),
                                hintText: '0',
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
                        controller: _sodiumController,
                        decoration: const InputDecoration(
                          labelText: 'Sodium (mg)',
                          border: OutlineInputBorder(),
                          hintText: '0',
                        ),
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(
                            RegExp(r'^\d+\.?\d{0,2}'),
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
